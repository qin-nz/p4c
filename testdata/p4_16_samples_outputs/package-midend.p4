control proto(out bit<32> o);
package top(proto _c, bool parameter);
control c(out bit<32> o) {
    action act() {
        o = 32w0;
    }
    table tbl_act {
        actions = {
            act();
        }
        const default_action = act();
    }
    apply {
        tbl_act.apply();
    }
}

top(c(), true) main;
