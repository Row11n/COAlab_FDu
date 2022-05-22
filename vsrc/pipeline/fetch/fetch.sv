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
    input u1 stallM,
    input u1 is_ls
);

    assign stallI = ireq.valid && ~iresp.data_ok;
    assign dataF.pc = pc;
    assign ireq.addr = pc;


    always_latch 
    begin 
        if(is_ls == 1'b1)
            ireq.valid = 1'b0;
    end

    always_latch 
    begin 
        if(stallM == 1'b1 || pc == '0 || dresp.data_ok == 1'b1)
            ireq.valid = 1'b1;
    end

    assign dataF.raw_instr = ireq.valid ? iresp.data : '0; 

endmodule
`endif

