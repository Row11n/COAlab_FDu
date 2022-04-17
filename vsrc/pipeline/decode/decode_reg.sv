`ifndef __DECODE_REG_SV
`define __DECODE_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module decode_reg
    import common::*;
    import pipes::*;
(
    input clk, reset,
    input decode_data_t dataD,
    output decode_data_t dataD_nxt,
    input u1 stallM
);
     always_ff @(posedge clk)
     begin
         if(reset)
         begin
         end
         else if(stallM)
         begin
             dataD_nxt <= dataD_nxt;
         end
         else
         begin
             dataD_nxt <= dataD;
         end
     end

endmodule
`endif 