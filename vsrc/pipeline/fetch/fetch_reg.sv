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
    output fetch_data_t dataF_nxt,
    input u1 stall,
    input u1 jump,
    input u1 stallM,
    input u1 stallI,
    output u1 stallI_nxt
);

    always_ff @(posedge clk)
    begin
    if(reset)
         begin
         end
    else
    begin
        if(stall || jump || stallM || stallI)
        begin
            dataF_nxt.raw_instr <= '0;
            dataF_nxt.pc <= dataF.pc;
        end
        else
        begin
            dataF_nxt <= dataF;
        end
        stallI_nxt <= stallI;
    end
    end

endmodule
`endif