`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c
);
	u64 t1;
	always_comb 
	begin
		c = '0;
		t1 = '0;
		unique case(alufunc)
			ALU_ADD: c = a + b;
			ALU_OR: c = a | b;
			ALU_SUB: c = a - b;
			ALU_XOR: c = a ^ b;
			ALU_AND: c = a & b;
			ALU_SRL: c = a >> b[5:0];
			ALU_SLL: c = a << b[5:0];
			ALU_SRA: c = $signed(a) >> b[5:0];
			ALU_FUCKING: c = a;
			ALU_SUCKING: c = b;
			ALU_SLT: c = {{63{1'b0}}, ($signed(a) < $signed(b))};
			ALU_SLTU: c = {{63{1'b0}}, (a < b)};

			ALU_ADDW:
			begin
				t1 = a + b;
				c = {{32{t1[31]}}, t1[31:0]};
			end

			ALU_SLLW:
			begin
				t1 = a << b[4:0];
				c = {{32{t1[31]}}, t1[31:0]};
			end

			ALU_SUBW:
			begin
				t1 = a - b;
				c = {{32{t1[31]}}, t1[31:0]};
			end

			ALU_SRAW:
			begin
				t1 = $signed(a) >> b[4:0];
				c = {{32{t1[31]}}, t1[31:0]};
			end
			
			ALU_SRLW:
			begin
				t1 = a >> b[4:0];
				c = {{32{t1[31]}}, t1[31:0]};
			end

			default: 
			begin
			end
		endcase
	end
	
endmodule

`endif
