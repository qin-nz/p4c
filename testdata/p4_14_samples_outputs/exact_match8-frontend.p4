#include <core.p4>
#include <v1model.p4>

header data_t {
    bit<32> f1;
    bit<32> f2;
    bit<32> f3;
    bit<32> f4;
    bit<8>  b1;
    bit<8>  b2;
    bit<8>  b3;
    bit<8>  b4;
}

struct metadata {
}

struct headers {
    @name("data") 
    data_t data;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("start") state start {
        packet.extract<data_t>(hdr.data);
        transition accept;
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".noop") action noop_0() {
    }
    @name(".setb1") action setb1_0(bit<8> val) {
        hdr.data.b1 = val;
    }
    @name(".setb2") action setb2_0(bit<8> val) {
        hdr.data.b2 = val;
    }
    @name(".setb3") action setb3_0(bit<8> val) {
        hdr.data.b3 = val;
    }
    @name(".setb4") action setb4_0(bit<8> val) {
        hdr.data.b4 = val;
    }
    @name(".setb12") action setb12_0(bit<8> v1, bit<8> v2) {
        hdr.data.b1 = v1;
        hdr.data.b2 = v2;
    }
    @name(".setb13") action setb13_0(bit<8> v1, bit<8> v2) {
        hdr.data.b1 = v1;
        hdr.data.b3 = v2;
    }
    @name(".setb14") action setb14_0(bit<8> v1, bit<8> v2) {
        hdr.data.b1 = v1;
        hdr.data.b4 = v2;
    }
    @name(".setb23") action setb23_0(bit<8> v1, bit<8> v2) {
        hdr.data.b2 = v1;
        hdr.data.b3 = v2;
    }
    @name(".setb24") action setb24_0(bit<8> v1, bit<8> v2) {
        hdr.data.b2 = v1;
        hdr.data.b4 = v2;
    }
    @name(".setb34") action setb34_0(bit<8> v1, bit<8> v2) {
        hdr.data.b3 = v1;
        hdr.data.b4 = v2;
    }
    @name("test1") table test1_0 {
        actions = {
            noop_0();
            setb1_0();
            setb2_0();
            setb3_0();
            setb4_0();
            setb12_0();
            setb13_0();
            setb14_0();
            setb23_0();
            setb24_0();
            setb34_0();
            @default_only NoAction();
        }
        key = {
            hdr.data.f1: exact @name("hdr.data.f1") ;
        }
        default_action = NoAction();
    }
    apply {
        test1_0.apply();
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<data_t>(hdr.data);
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
