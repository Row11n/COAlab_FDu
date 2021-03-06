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
    input clk, reset,
    input decode_data_t dataD,
    output execute_data_t dataE,
    output forward_data_t forwardE,
    output u1 stallE
);
    word_t result_alu;

    alu alu
    (
        .clk(clk),
		.reset(reset),
        .a(dataD.srca),
        .b(dataD.srcb),
        .alufunc(dataD.ctl.alufunc),
        .c(result_alu),
        .stallE(stallE)
    );

    assign dataE.pc = dataD.pc;
    assign dataE.ctl = dataD.ctl;
    assign dataE.result_alu = result_alu;
    assign dataE.wd = dataD.wd;
    assign dataE.wa = dataD.dst;

    
    assign forwardE.wa = dataE.wa;
    assign forwardE.result = dataE.result_alu;
    assign forwardE.regwrite = dataE.ctl.regwrite;
    
endmodule
`endif