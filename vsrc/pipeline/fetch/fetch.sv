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
    output u1 stallI,
    input u1 stallM,
    input u1 stallI_nxt
);

    assign stallI = ireq.valid && ~iresp.data_ok;
    assign dataF.pc = pc;
    assign ireq.addr = pc;

    always_comb
    begin
        if(stallI_nxt == '0 && stallM == 1)
            ireq.valid = 1'b0;
        else
            ireq.valid = 1'b1;
    end

    assign dataF.raw_instr = iresp.data; 

endmodule
`endif

