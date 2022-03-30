`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`include "pipeline/decode/extender.sv"

`else
`endif 

module decode
    import common::*;
    import pipes::*;
(
    input fetch_data_t dataF,
    output decode_data_t dataD,
    output creg_addr_t ra1, ra2,
    input word_t rd1, rd2,
    input forward_data_t forward,
    output u1 stall
);
    control_t ctl;
    decoder decoder
    (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .ra1(ra1),
        .ra2(ra2)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.raw_instr[11:7];
    assign dataD.wd = rd2;

    //scra
    always_comb
    begin
        if(ra1 != '0 && ra1 == forward.waE && forward.regwriteE == 1'b1)
            dataD.srca = forward.resultE;
        else if(ra1 != '0 && ra1 == forward.waM && forward.regwriteM == 1'b1)
            dataD.srca = forward.resultM;
        else if(ra1 != '0 && ra1 == forward.waW && forward.regwriteW == 1'b1)
            dataD.srca = forward.resultW;
        else
            dataD.srca = rd1;
    end

    //scrb
    extender extender
    (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .pc(dataF.pc),
        .rd2(rd2),
        .srcb(dataD.srcb),
        .forward(forward),
        .ra2(ra2)
    );
    assign dataD.pc = dataF.pc;

    //ifstall
    always_comb
    begin
        if(ctl.memread == 1'b1 && ctl.regwrite == 1'b1)
            stall = 1'b1;
        else
            stall = 1'b0;
    end


endmodule
`endif 