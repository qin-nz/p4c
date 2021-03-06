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

/* -*-c++-*- */

#ifndef P4C_LIB_EXCEPTIONS_H_
#define P4C_LIB_EXCEPTIONS_H_

#include <exception>
#include "lib/error.h"

namespace Util {

// Base class for all exceptions.
// The constructor uses boost::format for the format string, i.e.,
// %1%, %2%, etc (starting at 1, not at 0)
class P4CExceptionBase : public std::exception {
 protected:
    cstring message;

 public:
    template <typename... T>
    P4CExceptionBase(const char* format, T... args) {
        boost::format fmt(format);
        this->message = ::bug_helper(fmt, "", "", "", std::forward<T>(args)...);
    }

    const char* what() const noexcept
    { return this->message.c_str(); }
};

// This class indicates a bug in the compiler
class CompilerBug final : public P4CExceptionBase {
 public:
    template <typename... T>
    CompilerBug(const char* format, T... args)
            : P4CExceptionBase(format, args...)
    { message = "COMPILER BUG:\n" + message; }
    template <typename... T>
    CompilerBug(const char* file, int line, const char* format, T... args)
            : P4CExceptionBase(format, args...)
    { message = cstring("COMPILER BUG: ") + file + ":" + Util::toString(line) + "\n" + message; }
};

// This class indicates a compilation error that we do not want to recover from.
// This may be due to a malformed input program.
// TODO: this class is very seldom used, perhaps we can remove it.
class CompilationError : public P4CExceptionBase {
 public:
    template <typename... T>
    CompilationError(const char* format, T... args)
            : P4CExceptionBase(format, args...) {}
};

#define BUG(...) do { throw Util::CompilerBug(__FILE__, __LINE__, __VA_ARGS__); } while (0)
#define BUG_CHECK(e, ...) do { if (!(e)) BUG(__VA_ARGS__); } while (0)

}  // namespace Util
#endif /* P4C_LIB_EXCEPTIONS_H_ */
