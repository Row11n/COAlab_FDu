`ifndef __WRITEBACK_SV
`define __WRITEBACK_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module writeback
    import common::*;
    import pipes::*;
(
    input memory_data_t dataM,
    output u1 regwrite,
    output creg_addr_t wa,
    output word_t result,
    output forward_data_t forward,
    output u64 pc_result,
    output u1 pc_valid,
    output u1 skip
);

    assign regwrite = dataM.ctl.regwrite;
    assign wa = dataM.wa;
    assign pc_result = dataM.pc;

    always_comb
    begin
        if(dataM.ctl.memwrite == 1'b1 || dataM.ctl.memread == 1'b1) 
        begin
            result = dataM.wd;
            if(dataM.addr_31 == 1'b0)
                skip = 1'b1;
            else
                skip = 1'b0;
        end
        else
        begin
            result = dataM.result_alu;
            skip = 1'b0;
        end
    end

    assign forward.waW = dataM.wa;
    assign forward.resultW = result;
    assign forward.regwriteW = regwrite;

    assign pc_valid = ~dataM.ctl.nop_signal;

endmodule
`endif 