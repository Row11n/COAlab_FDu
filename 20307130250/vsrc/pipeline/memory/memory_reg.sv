`ifndef __MEMORY_REG_SV
`define __MEMORY_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module memory_reg
    import common::*;
    import pipes::*;
(
    input clk, reset,
    input memory_data_t dataM,
    output memory_data_t dataM_nxt
);
    always_ff @(posedge clk)
    begin
    if(reset)
         begin

         end
         else
         begin
             dataM_nxt <= dataM;
         end
    end

endmodule
`endif 