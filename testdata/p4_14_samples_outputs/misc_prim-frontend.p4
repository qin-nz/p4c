#include <core.p4>
#include <v1model.p4>

header pkt_t {
    bit<32> field_a_32;
    int<32> field_b_32;
    bit<32> field_c_32;
    bit<32> field_d_32;
    bit<16> field_e_16;
    bit<16> field_f_16;
    bit<16> field_g_16;
    bit<16> field_h_16;
    bit<8>  field_i_8;
    bit<8>  field_j_8;
    bit<8>  field_k_8;
    bit<8>  field_l_8;
    int<32> field_x_32;
}

struct metadata {
}

struct headers {
    @name("pkt") 
    pkt_t pkt;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("parse_ethernet") state parse_ethernet {
        packet.extract<pkt_t>(hdr.pkt);
        transition accept;
    }
    @name("start") state start {
        transition parse_ethernet;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    bit<32> tmp;
    bit<32> tmp_0;
    bit<32> tmp_1;
    int<32> tmp_2;
    int<32> tmp_3;
    @name(".action_0") action action_14() {
        hdr.pkt.field_a_32 = (bit<32>)~(hdr.pkt.field_b_32 | (int<32>)hdr.pkt.field_c_32);
    }
    @name(".action_1") action action_15(bit<32> param0) {
        hdr.pkt.field_a_32 = ~(param0 & hdr.pkt.field_c_32);
    }
    @name(".action_2") action action_16(bit<32> param0) {
        hdr.pkt.field_a_32 = (bit<32>)~(hdr.pkt.field_b_32 ^ (int<32>)param0);
    }
    @name(".action_3") action action_17() {
        hdr.pkt.field_a_32 = ~hdr.pkt.field_d_32;
    }
    @name(".action_4") action action_18(bit<32> param0) {
        if (hdr.pkt.field_d_32 <= param0) 
            tmp = hdr.pkt.field_d_32;
        else 
            tmp = param0;
        hdr.pkt.field_a_32 = tmp;
    }
    @name(".action_5") action action_19(bit<32> param0) {
        if (param0 >= hdr.pkt.field_d_32) 
            tmp_0 = param0;
        else 
            tmp_0 = hdr.pkt.field_d_32;
        hdr.pkt.field_a_32 = tmp_0;
    }
    @name(".action_6") action action_20() {
        if (hdr.pkt.field_d_32 <= 32w7) 
            tmp_1 = hdr.pkt.field_d_32;
        else 
            tmp_1 = 32w7;
        hdr.pkt.field_b_32 = (int<32>)tmp_1;
    }
    @name(".action_7") action action_21(int<32> param0) {
        if (param0 >= (int<32>)hdr.pkt.field_d_32) 
            tmp_2 = param0;
        else 
            tmp_2 = (int<32>)hdr.pkt.field_d_32;
        hdr.pkt.field_b_32 = tmp_2;
    }
    @name(".action_8") action action_22(int<32> param0) {
        if (hdr.pkt.field_x_32 >= param0) 
            tmp_3 = hdr.pkt.field_x_32;
        else 
            tmp_3 = param0;
        hdr.pkt.field_x_32 = tmp_3;
    }
    @name(".action_9") action action_23() {
        hdr.pkt.field_x_32 = hdr.pkt.field_x_32 >> 7;
    }
    @name(".action_10") action action_24(bit<32> param0) {
        hdr.pkt.field_a_32 = ~param0 & hdr.pkt.field_a_32;
    }
    @name(".action_11") action action_25(bit<32> param0) {
        hdr.pkt.field_a_32 = param0 & ~hdr.pkt.field_a_32;
    }
    @name(".action_12") action action_26(bit<32> param0) {
        hdr.pkt.field_a_32 = ~param0 | hdr.pkt.field_a_32;
    }
    @name(".action_13") action action_27(bit<32> param0) {
        hdr.pkt.field_a_32 = param0 | ~hdr.pkt.field_a_32;
    }
    @name(".do_nothing") action do_nothing_0() {
    }
    @name("table_0") table table_1 {
        actions = {
            action_14();
            action_15();
            action_16();
            action_17();
            action_18();
            action_19();
            action_20();
            action_21();
            action_22();
            action_23();
            action_24();
            action_25();
            action_26();
            action_27();
            do_nothing_0();
            @default_only NoAction();
        }
        key = {
            hdr.pkt.field_a_32: ternary @name("hdr.pkt.field_a_32") ;
            hdr.pkt.field_b_32: ternary @name("hdr.pkt.field_b_32") ;
            hdr.pkt.field_c_32: ternary @name("hdr.pkt.field_c_32") ;
            hdr.pkt.field_d_32: ternary @name("hdr.pkt.field_d_32") ;
            hdr.pkt.field_g_16: ternary @name("hdr.pkt.field_g_16") ;
            hdr.pkt.field_h_16: ternary @name("hdr.pkt.field_h_16") ;
        }
        size = 512;
        default_action = NoAction();
    }
    apply {
        table_1.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<pkt_t>(hdr.pkt);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
