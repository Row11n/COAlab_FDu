`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module memory
    import common::*;
    import pipes::*;
(
    input execute_data_t dataE,
    output memory_data_t dataM,
    output forward_data_t forward
);
    
    assign dataM.pc = dataE.pc;
    assign dataM.ctl = dataE.ctl;
    assign dataM.result = dataE.result_alu; //temporary
    assign dataM.wa = dataE.wa;

    assign forward.waM = dataM.wa;
    assign forward.resultM =  dataM.result;
    assign forward.regwriteM = dataM.ctl.regwrite;



endmodule
`endif 