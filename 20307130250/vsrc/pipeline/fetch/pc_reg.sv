`ifndef __PC_REG_SV
`define __PC_REG_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/fetch/pcselect.sv"

`else
`endif 

module pc_reg
    import common::*;
    import pipes::*;
(
    input logic clk, reset,
    output u64 pc,
	input u1 stall,
	input u1 jump,
	input u64 pcsrc,
	input u1 stallM,
	input u1 stallI,
	input u1 stallE
);

    u64 pc_nxt;
    pcselect pcselect
	(
		.pcplus4(pc + 4),
		.pcsrc(pcsrc),
		.pc_selected(pc_nxt),
		.stall(stall),
		.jump(jump),
		.stallM(stallM),
		.stallI(stallI),
		.stallE(stallE)
	);

    always_ff @(posedge clk)
	begin
		if(reset)
		begin
			pc <= 64'h8000_0000;
		end
		else
		begin
			pc <= pc_nxt;
		end
	end

endmodule
`endif