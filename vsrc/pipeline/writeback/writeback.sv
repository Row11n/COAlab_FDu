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
    output forward_data_t forward
);

    assign regwrite = dataM.ctl.regwrite;
    assign wa = dataM.wa;

    always_comb
    begin
        if(dataM.ctl.memwrite == 1'b1 || dataM.ctl.memread == 1'b1) 
        begin
            result = dataM.wd;
        end
        else
        begin
            result = dataM.result;
        end
    end

    assign forward.waW = dataM.wa;
    assign forward.resultW = result;
    assign forward.regwriteW = regwrite;

endmodule
`endif 