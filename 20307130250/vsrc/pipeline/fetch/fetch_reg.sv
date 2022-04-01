`ifndef __FETCH_REG_SV
`define __FETCH_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module fetch_reg
    import common::*;
    import pipes::*;
(
    input clk, reset,
    input fetch_data_t dataF,
    output fetch_data_t dataF_nxt
);

    always_ff @(posedge clk)
    begin
    if(reset)
         begin
         end
         else
         begin
             dataF_nxt <= dataF;
         end
    end

endmodule
`endif