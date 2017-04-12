/*
Copyright 2013-present Barefoot Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include "moveConstructors.h"

namespace P4 {

struct ConstructorMap {
    // Maps a constructor to the temporary used to hold its value.
    ordered_map<const IR::ConstructorCallExpression*, cstring> tmpName;

    void clear() { tmpName.clear(); }
    void add(const IR::ConstructorCallExpression* expression, cstring name)
    { CHECK_NULL(expression); tmpName[expression] = name; }
    bool empty() const { return tmpName.empty(); }
};

namespace {
// Converts constructor call expressions that appear
// within the bodies of P4Parser and P4Control blocks
// into Declaration_Instance.  This is needed for implementing
// copy-in/copy-out in inlining, since
// constructed objects do not have assignment operations.
// For example:
// extern T {}
// control c()(T t) {  apply { ... } }
// control d() {
//    c(T()) cinst;
//    apply { ... }
// }
// is converted to
// extern T {}
// control c()(T t) {  apply { ... } }
// control d() {
//    T() tmp;
//    c(tmp) cinst;
//    apply { ... }
// }
class MoveConstructorsImpl : public Transform {
    enum class Region {
        InParserStateful,
        InControlStateful,
        InBody,
        Outside
    };

    ReferenceMap*   refMap;
    ConstructorMap  cmap;
    Region          convert;

 public:
    explicit MoveConstructorsImpl(ReferenceMap* refMap) :
            refMap(refMap), convert(Region::Outside) { setName("MoveConstructorsImpl"); }

    const IR::Node* preorder(IR::P4Parser* parser) override {
        cmap.clear();
        convert = Region::InParserStateful;
        visit(parser->parserLocals);
        convert = Region::InBody;
        visit(parser->states);
        convert = Region::Outside;
        prune();
        return parser;
    }

    const IR::Node* preorder(IR::IndexedVector<IR::Declaration>* declarations) override {
        if (convert != Region::InParserStateful)
            return declarations;

        bool changes = false;
        auto result = new IR::Vector<IR::Declaration>();
        for (auto s : *declarations) {
            visit(s);
            for (auto e : cmap.tmpName) {
                auto cce = e.first;
                auto decl = new IR::Declaration_Instance(
                    cce->srcInfo, e.second, cce->constructedType, cce->arguments);
                result->push_back(decl);
                changes = true;
            }
            result->push_back(s);
            cmap.clear();
        }
        prune();
        if (changes)
            return result;
        return declarations;
    }

    const IR::Node* postorder(IR::P4Parser* parser) override {
        if (cmap.empty())
            return parser;
        auto newDecls = new IR::IndexedVector<IR::Declaration>();
        for (auto e : cmap.tmpName) {
            auto cce = e.first;
            auto decl = new IR::Declaration_Instance(
                cce->srcInfo, e.second, cce->constructedType, cce->arguments);
            newDecls->push_back(decl);
        }
        newDecls->append(*parser->parserLocals);
        auto result = new IR::P4Parser(parser->srcInfo, parser->name, parser->type,
                                       parser->constructorParams, newDecls, parser->states);
        return result;
    }

    const IR::Node* preorder(IR::P4Control* control) override {
        cmap.clear();
        convert = Region::InControlStateful;
        auto newDecls = new IR::IndexedVector<IR::Declaration>();
        bool changes = false;
        for (auto decl : *control->controlLocals) {
            visit(decl);
            for (auto e : cmap.tmpName) {
                auto cce = e.first;
                auto inst = new IR::Declaration_Instance(
                    cce->srcInfo, e.second, cce->constructedType, cce->arguments);
                newDecls->push_back(inst);
                changes = true;
            }
            newDecls->push_back(decl);
            cmap.clear();
        }
        convert = Region::InBody;
        visit(control->body);
        convert = Region::Outside;
        prune();
        if (changes) {
            auto result = new IR::P4Control(control->srcInfo, control->name, control->type,
                                            control->constructorParams, newDecls,
                                            control->body);
            return result;
        }
        return control;
    }

    const IR::Node* postorder(IR::P4Control* control) override {
        if (cmap.empty())
            return control;
        auto newDecls = new IR::IndexedVector<IR::Declaration>();
        for (auto e : cmap.tmpName) {
            auto cce = e.first;
            auto decl = new IR::Declaration_Instance(
                cce->srcInfo, e.second, cce->constructedType, cce->arguments);
            newDecls->push_back(decl);
        }
        newDecls->append(*control->controlLocals);
        auto result = new IR::P4Control(control->srcInfo, control->name, control->type,
                                        control->constructorParams, newDecls,
                                        control->body);
        return result;
    }

    const IR::Node* preorder(IR::P4Table* table) override
    { prune(); return table; }  // skip

    const IR::Node* postorder(IR::ConstructorCallExpression* expression) override {
        if (convert == Region::Outside)
            return expression;
        auto tmpvar = refMap->newName("tmp");
        auto tmpref = new IR::PathExpression(IR::ID(expression->srcInfo, tmpvar));
        cmap.add(expression, tmpvar);
        return tmpref;
    }
};
}  // namespace

MoveConstructors::MoveConstructors(ReferenceMap* refMap) {
    setName("MoveConstructors");
    passes.emplace_back(new P4::ResolveReferences(refMap));
    passes.emplace_back(new MoveConstructorsImpl(refMap));
}

}  // namespace P4
