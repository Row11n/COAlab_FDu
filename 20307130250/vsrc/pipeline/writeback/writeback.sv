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
    output word_t result
);

    assign regwrite = dataM.ctl.regwrite;
    assign wa = dataM.wa;
    assign result = dataM.result;

endmodule
`endif 