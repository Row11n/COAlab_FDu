`ifndef __MEMORY_REG_SV
`define __MEMORY_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/writedata.sv"
`include "pipeline/memory/readdata.sv"
`else
`endif 

module memory_reg
    import common::*;
    import pipes::*;
(
    input clk, reset,
    input memory_data_t dataM,
    output memory_data_t dataM_nxt,
    input u1 stallM
);
    always_ff @(posedge clk)
    begin
    if(reset)
    begin
    end
    else if(stallM)
    begin
        dataM_nxt.pc <= dataM.pc;
        dataM_nxt.result_alu <= '0;
        dataM_nxt.wd <= '0;
        dataM_nxt.wa <= '0;
        dataM_nxt.addr_31 <= '0;
        dataM_nxt.ctl.op <= NOP;
        dataM_nxt.ctl.alufunc <= ALU_SUCKING;
        dataM_nxt.ctl.regwrite <= '0;
        dataM_nxt.ctl.memwrite <= '0;
        dataM_nxt.ctl.memread <= '0;
        dataM_nxt.ctl.branch <= '0;
        dataM_nxt.ctl.nop_signal <= 1'b1;
    end
    else
        dataM_nxt <= dataM;
    end

endmodule
`endif 