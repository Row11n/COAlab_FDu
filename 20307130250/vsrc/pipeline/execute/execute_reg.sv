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
    input u1 stallM,
    input u1 stallE
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

    else if (stallE)
    begin
        dataE_nxt.pc <= dataE.pc;
        dataE_nxt.result_alu <= '0;
        dataE_nxt.wd <= '0;
        dataE_nxt.wa <= '0;
        dataE_nxt.ctl.op <= NOP;
        dataE_nxt.ctl.alufunc <= ALU_SUCKING;
        dataE_nxt.ctl.regwrite <= '0;
        dataE_nxt.ctl.memwrite <= '0;
        dataE_nxt.ctl.memread <= '0;
        dataE_nxt.ctl.branch <= '0;
        dataE_nxt.ctl.nop_signal <= 1'b1;
    end

    else
    begin
        dataE_nxt <= dataE;
    end
    end

endmodule

`endif