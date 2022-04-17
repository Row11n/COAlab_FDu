`ifndef __EXECUTE_REG_SV
`define __EXECUTE_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module execute_reg
    import common::*;
    import pipes::*;
(
    input clk, reset,
    input execute_data_t dataE,
    output execute_data_t dataE_nxt,
    input u1 stallM
);
    always_ff @(posedge clk)
    begin
    if(reset)
    begin

    end
    else if(stallM)
    begin
        dataE_nxt <= dataE_nxt;
    end
    else
    begin
        dataE_nxt <= dataE;
    end
    end

endmodule

`endif