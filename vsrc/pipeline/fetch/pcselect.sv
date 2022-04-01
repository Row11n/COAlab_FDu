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
    input u1 jump
);

    always_comb
    begin
        if(stall)
            pc_selected = pcplus4 - 4;
        else if(jump)
            pc_selected = pcsrc;
        else
            pc_selected = pcplus4;
    end

endmodule
`endif

