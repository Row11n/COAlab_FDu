`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`else
`endif 

module decode
    import common::*;
    import pipes::*;
(
    input fetch_data_t dataF,
    output decode_data_t dataD,
    output creg_addr_t ra1, ra2,
    input word_t rd1, rd2
);
    control_t ctl;
    u1 is_im;
    decoder decoder
    (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .ra1(ra1),
        .ra2(ra2),
        .is_im(is_im)
    );

    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.raw_instr[11:7];
    assign dataD.srca = rd1;
    always_comb
    begin
        if(is_im)
            dataD.srcb = {{52{dataF.raw_instr[31]}}, dataF.raw_instr[31:20]};
        else
            dataD.srcb = rd2;
    end
    assign dataD.pc = dataF.pc;

endmodule
`endif 