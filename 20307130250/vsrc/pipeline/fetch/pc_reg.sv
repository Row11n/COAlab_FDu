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
    output u64 pc
);

    u64 pc_nxt;
    pcselect pcselect
	(
		.pcplus4(pc + 4),
		.pc_selected(pc_nxt)
	);

    always_ff @( posedge clk )
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