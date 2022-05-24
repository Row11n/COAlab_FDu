`ifndef __PCSELECT_SV
`define __PCSELECT_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv" 
`else

`endif 

module pcselect
import common::*;
import pipes::*;
(
    input u64 pcplus4,
    input u64 pcsrc,
    output u64 pc_selected,
    input u1 stall,
    input u1 jump,
    input u1 stallM,
    input u1 stallI,
    input u1 stallE
);

    always_comb
    begin
        if(jump)
            pc_selected = pcsrc;
        else if(stall || stallM || stallI || stallE)
            pc_selected = pcplus4 - 4;
        else
            pc_selected = pcplus4;
    end

endmodule
`endif

