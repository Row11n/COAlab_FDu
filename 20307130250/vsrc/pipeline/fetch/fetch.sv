`ifndef __FETCH_SV
`define __FETCH_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv" 
`else

`endif 

module fetch
import common::*;
import pipes::*;
(
    output fetch_data_t dataF,
    input u64 pc,
    output ibus_req_t ireq,
    input ibus_resp_t iresp,
    input dbus_resp_t dresp,
    output u1 stallI,
    input u1 stallM
);

    assign stallI = ireq.valid && ~iresp.data_ok;
    assign dataF.pc = pc;
    assign ireq.addr = pc;
    assign ireq.valid = 1'b1;

    assign dataF.raw_instr = ireq.valid ? iresp.data : '0; 

endmodule
`endif

