`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/alu.sv"
`else
`endif 

module execute
    import common::*;
    import pipes::*;
(
    input decode_data_t dataD,
    output execute_data_t dataE,
    output forward_data_t forward
);
    word_t result_alu;

    alu alu
    (
        .a(dataD.srca),
        .b(dataD.srcb),
        .alufunc(dataD.ctl.alufunc),
        .c(result_alu)
    );

    assign dataE.pc = dataD.pc;
    assign dataE.ctl = dataD.ctl;
    assign dataE.result_alu = result_alu;
    assign dataE.wd = dataD.wd;
    assign dataE.wa = dataD.dst;

    
    assign forward.waE = dataE.wa;
    assign forward.resultE = dataE.result_alu;
    assign forward.regwriteE = dataE.ctl.regwrite;
    
endmodule
`endif