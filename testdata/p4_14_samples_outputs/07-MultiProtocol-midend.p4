#include <core.p4>
#include <v1model.p4>

struct ingress_metadata_t {
    bit<1> drop;
    bit<9> egress_port;
    bit<4> packet_type;
}

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header icmp_t {
    bit<16> typeCode;
    bit<16> hdrChecksum;
}

header ipv4_t {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<3>  flags;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header ipv6_t {
    bit<4>   version;
    bit<8>   trafficClass;
    bit<20>  flowLabel;
    bit<16>  payloadLen;
    bit<8>   nextHdr;
    bit<8>   hopLimit;
    bit<128> srcAddr;
    bit<128> dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<4>  res;
    bit<8>  flags;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header udp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<16> length_;
    bit<16> checksum;
}

header vlan_tag_t {
    bit<3>  pcp;
    bit<1>  cfi;
    bit<12> vid;
    bit<16> etherType;
}

struct metadata {
    @name("ing_metadata") 
    ingress_metadata_t ing_metadata;
}

struct headers {
    @name("ethernet") 
    ethernet_t ethernet;
    @name("icmp") 
    icmp_t     icmp;
    @name("ipv4") 
    ipv4_t     ipv4;
    @name("ipv6") 
    ipv6_t     ipv6;
    @name("tcp") 
    tcp_t      tcp;
    @name("udp") 
    udp_t      udp;
    @name("vlan_tag") 
    vlan_tag_t vlan_tag;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("parse_icmp") state parse_icmp {
        packet.extract<icmp_t>(hdr.icmp);
        transition accept;
    }
    @name("parse_ipv4") state parse_ipv4 {
        packet.extract<ipv4_t>(hdr.ipv4);
        transition select(hdr.ipv4.fragOffset, hdr.ipv4.ihl, hdr.ipv4.protocol) {
            (13w0x0 &&& 13w0x0, 4w0x5 &&& 4w0xf, 8w0x1 &&& 8w0xff): parse_icmp;
            (13w0x0 &&& 13w0x0, 4w0x5 &&& 4w0xf, 8w0x6 &&& 8w0xff): parse_tcp;
            (13w0x0 &&& 13w0x0, 4w0x5 &&& 4w0xf, 8w0x11 &&& 8w0xff): parse_udp;
            default: accept;
        }
    }
    @name("parse_ipv6") state parse_ipv6 {
        packet.extract<ipv6_t>(hdr.ipv6);
        transition select(hdr.ipv6.nextHdr) {
            8w0x1: parse_icmp;
            8w0x6: parse_tcp;
            8w0x11: parse_udp;
            default: accept;
        }
    }
    @name("parse_tcp") state parse_tcp {
        packet.extract<tcp_t>(hdr.tcp);
        transition accept;
    }
    @name("parse_udp") state parse_udp {
        packet.extract<udp_t>(hdr.udp);
        transition accept;
    }
    @name("parse_vlan_tag") state parse_vlan_tag {
        packet.extract<vlan_tag_t>(hdr.vlan_tag);
        transition select(hdr.vlan_tag.etherType) {
            16w0x800: parse_ipv4;
            16w0x86dd: parse_ipv6;
            default: accept;
        }
    }
    @name("start") state start {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            16w0x8100: parse_vlan_tag;
            16w0x9100: parse_vlan_tag;
            16w0x800: parse_ipv4;
            16w0x86dd: parse_ipv6;
            default: accept;
        }
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("NoAction") action NoAction_0() {
    }
    @name("NoAction") action NoAction_9() {
    }
    @name("NoAction") action NoAction_10() {
    }
    @name("NoAction") action NoAction_11() {
    }
    @name("NoAction") action NoAction_12() {
    }
    @name("NoAction") action NoAction_13() {
    }
    @name("NoAction") action NoAction_14() {
    }
    @name("NoAction") action NoAction_15() {
    }
    @name(".l2_packet") action l2_packet_0() {
        meta.ing_metadata.packet_type = 4w0;
    }
    @name(".ipv4_packet") action ipv4_packet_0() {
        meta.ing_metadata.packet_type = 4w1;
    }
    @name(".ipv6_packet") action ipv6_packet_0() {
        meta.ing_metadata.packet_type = 4w2;
    }
    @name(".mpls_packet") action mpls_packet_0() {
        meta.ing_metadata.packet_type = 4w3;
    }
    @name(".mim_packet") action mim_packet_0() {
        meta.ing_metadata.packet_type = 4w4;
    }
    @name(".nop") action nop_0() {
    }
    @name(".nop") action nop_7() {
    }
    @name(".nop") action nop_8() {
    }
    @name(".nop") action nop_9() {
    }
    @name(".nop") action nop_10() {
    }
    @name(".nop") action nop_11() {
    }
    @name(".nop") action nop_12() {
    }
    @name(".drop") action drop_0() {
        meta.ing_metadata.drop = 1w1;
    }
    @name(".drop") action drop_4() {
        meta.ing_metadata.drop = 1w1;
    }
    @name(".drop") action drop_5() {
        meta.ing_metadata.drop = 1w1;
    }
    @name(".set_egress_port") action set_egress_port_0(bit<9> egress_port) {
        meta.ing_metadata.egress_port = egress_port;
    }
    @name(".set_egress_port") action set_egress_port_3(bit<9> egress_port) {
        meta.ing_metadata.egress_port = egress_port;
    }
    @name(".set_egress_port") action set_egress_port_4(bit<9> egress_port) {
        meta.ing_metadata.egress_port = egress_port;
    }
    @name(".send_packet") action send_packet_0() {
        standard_metadata.egress_spec = meta.ing_metadata.egress_port;
    }
    @name("ethertype_match") table ethertype_match {
        actions = {
            l2_packet_0();
            ipv4_packet_0();
            ipv6_packet_0();
            mpls_packet_0();
            mim_packet_0();
            @default_only NoAction_0();
        }
        key = {
            hdr.ethernet.etherType: exact @name("hdr.ethernet.etherType") ;
        }
        default_action = NoAction_0();
    }
    @name("icmp_check") table icmp_check {
        actions = {
            nop_0();
            drop_0();
            @default_only NoAction_9();
        }
        key = {
            hdr.icmp.typeCode: exact @name("hdr.icmp.typeCode") ;
        }
        default_action = NoAction_9();
    }
    @name("ipv4_match") table ipv4_match {
        actions = {
            nop_7();
            set_egress_port_0();
            @default_only NoAction_10();
        }
        key = {
            hdr.ipv4.dstAddr: exact @name("hdr.ipv4.dstAddr") ;
        }
        default_action = NoAction_10();
    }
    @name("ipv6_match") table ipv6_match {
        actions = {
            nop_8();
            set_egress_port_3();
            @default_only NoAction_11();
        }
        key = {
            hdr.ipv6.dstAddr: exact @name("hdr.ipv6.dstAddr") ;
        }
        default_action = NoAction_11();
    }
    @name("l2_match") table l2_match {
        actions = {
            nop_9();
            set_egress_port_4();
            @default_only NoAction_12();
        }
        key = {
            hdr.ethernet.dstAddr: exact @name("hdr.ethernet.dstAddr") ;
        }
        default_action = NoAction_12();
    }
    @name("set_egress") table set_egress {
        actions = {
            nop_10();
            send_packet_0();
            @default_only NoAction_13();
        }
        key = {
            meta.ing_metadata.drop: exact @name("meta.ing_metadata.drop") ;
        }
        default_action = NoAction_13();
    }
    @name("tcp_check") table tcp_check {
        actions = {
            nop_11();
            drop_4();
            @default_only NoAction_14();
        }
        key = {
            hdr.tcp.dstPort: exact @name("hdr.tcp.dstPort") ;
        }
        default_action = NoAction_14();
    }
    @name("udp_check") table udp_check {
        actions = {
            nop_12();
            drop_5();
            @default_only NoAction_15();
        }
        key = {
            hdr.udp.dstPort: exact @name("hdr.udp.dstPort") ;
        }
        default_action = NoAction_15();
    }
    apply {
        switch (ethertype_match.apply().action_run) {
            default: {
                l2_match.apply();
            }
            ipv4_packet_0: {
                ipv4_match.apply();
            }
            mpls_packet_0: 
            ipv6_packet_0: {
                ipv6_match.apply();
            }
        }

        if (hdr.tcp.isValid()) 
            tcp_check.apply();
        else 
            if (hdr.udp.isValid()) 
                udp_check.apply();
            else 
                if (hdr.icmp.isValid()) 
                    icmp_check.apply();
        set_egress.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<vlan_tag_t>(hdr.vlan_tag);
        packet.emit<ipv6_t>(hdr.ipv6);
        packet.emit<ipv4_t>(hdr.ipv4);
        packet.emit<udp_t>(hdr.udp);
        packet.emit<tcp_t>(hdr.tcp);
        packet.emit<icmp_t>(hdr.icmp);
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
