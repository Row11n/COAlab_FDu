`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv" 
`else

`endif 

module fetch
import common::*;
import pipes::*;
(
    input u32 raw_instr,
    output fetch_data_t dataF,
    input u64 pc
);
    assign dataF.raw_instr = raw_instr;
    assign dataF.pc = pc;


endmodule
`endif

