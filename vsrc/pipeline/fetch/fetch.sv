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
    input u32 raw_instr,
    output fetch_data_t dataF,
    input u64 pc,
    output ibus_req_t ireq,
    input ibus_resp_t iresp,
    output u1 stallI,
    input u1 stallM
);

    assign stallI = ireq.valid && ~iresp.data_ok;
    assign dataF.pc = pc;
    assign ireq.addr = pc;
	assign ireq.valid = 1'b1;

    always_comb
    begin
        if(stallI)
            dataF.raw_instr = '0;
        else
            dataF.raw_instr = iresp.data; 
    end

endmodule
`endif

