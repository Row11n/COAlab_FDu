`ifndef __ALU_SV
`define __ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/execute/multiplier_multicycle_dsp.sv"
`include "pipeline/execute/divider_multicycle.sv"
`else

`endif

module alu
	import common::*;
	import pipes::*;(
	input clk, reset,
	input u64 a, b,
	input alufunc_t alufunc,
	output u64 c,
	output u1 stallE
);

	u1 valid_mul;
	u1 valid_div;
	u1 done_mul, done_div;
	u64 _a, _b, _c;
	u128 res;
	multiplier_multicycle_dsp multiplier_multicycle_dsp(
		.clk(clk),
		.reset(reset),
		.valid(valid_mul),
		.done(done_mul),
		.a(_a),
		.b(_b),
		.c(_c)
	);
	divider_multicycle divider_multicycle(
		.clk(clk),
		.reset(reset),
		.valid(valid_div),
		.done(done_div),
		.a(_a),
		.b(_b),
		.res(res)
	);
	assign stallE = (valid_mul && ~done_mul) || (valid_div && ~done_div);



	u64 t1;
	always_comb 
	begin
		c = '0;
		t1 = '0;
		valid_mul = '0;
		valid_div = '0;
		_a = a;
		_b = b;
		unique case(alufunc)
			ALU_ADD: c = a + b;
			ALU_OR: c = a | b;
			ALU_SUB: c = a - b;
			ALU_XOR: c = a ^ b;
			ALU_AND: c = a & b;
			ALU_SRL: c = a >> b[5:0];
			ALU_SLL: c = a << b[5:0];
			ALU_SRA: c = $signed(a) >>> b[5:0];
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
				t1 = $signed({{32{a[31]}}, a[31:0]}) >>> b[4:0];
				c = {{32{t1[31]}}, t1[31:0]};
			end
			
			ALU_SRLW:
			begin
				t1 = {{32{1'b0}}, a[31:0] >> b[4:0]};
				c = {{32{t1[31]}}, t1[31:0]};
			end

			ALU_MUL:
			begin
				valid_mul = 1'b1;
				c = _c;
			end

			ALU_MULW:
			begin
				valid_mul = 1'b1;
				t1 = {{32{1'b0}}, _c[31:0]};
				c = {{32{t1[31]}}, t1[31:0]};
			end


			//todo 
			ALU_DIVU:
			begin
				if(b == '0)
					c = '1;
				else
				begin
					valid_div = 1'b1;
					c = res[63:0];
				end
			end

			ALU_DIV:
			begin
				if(b == '0)
					c = '1;
				else if(a[63] == 1'b1 && b[63] == 1'b0)
				begin
					_a = -a;
					valid_div = 1'b1;
					c = -res[63:0];
				end
				else if(a[63] == 1'b0 && b[63] == 1'b1)
				begin
					_b = -b;
					valid_div = 1'b1;
					c = -res[63:0];
				end
				else if(a[63] == 1'b1 && b[63] == 1'b1)
				begin
					_a = -a;
					_b = -b;
					valid_div = 1'b1;
					c = res[63:0];
				end
				else
				begin
					valid_div = 1'b1;
					c = res[63:0];
				end
			end

			ALU_DIVW:
			begin
				if(b[31:0] == '0)
					c = '1;
				else if(a[31] == 1'b1 && b[31] == 1'b0)
				begin
					_a = {32'b0, -a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, -res[31:0]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else if(a[31] == 1'b0 && b[31] == 1'b1)
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, -b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, -res[31:0]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else if(a[31] == 1'b1 && b[31] == 1'b1)
				begin
					_a = {32'b0, -a[31:0]};
					_b = {32'b0, -b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[31:0]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[31:0]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
			end

			ALU_DIVUW:
			begin
				if(b[31:0] == '0)
					c = '1;
				else
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[31:0]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
			end

			ALU_REM:
			begin
				if(b == '0)
					c = a;
				else if(a[63] == 1'b1 && b[63] == 1'b0)
				begin
					_a = -a;
					valid_div = 1'b1;
					c = -res[127:64];
				end
				else if(a[63] == 1'b0 && b[63] == 1'b1)
				begin
					_b = -b;
					valid_div = 1'b1;
					c = res[127:64];
				end
				else if(a[63] == 1'b1 && b[63] == 1'b1)
				begin
					_a = -a;
					_b = -b;
					valid_div = 1'b1;
					c = -res[127:64];
				end
				else
				begin
					valid_div = 1'b1;
					c = res[127:64];
				end
			end

			ALU_REMU:
			begin
				if(b == '0)
					c = a;
				begin
					valid_div = 1'b1;
					c = res[127:64];
				end
			end

			ALU_REMW:
			begin
				if(b[31:0] == '0)
					c = {{32{a[31]}}, a[31:0]};
				else if(a[31] == 1'b1 && b[31] == 1'b0)
				begin
					_a = {32'b0, -a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, -res[95:64]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else if(a[31] == 1'b0 && b[31] == 1'b1)
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, -b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[95:64]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else if(a[31] == 1'b1 && b[31] == 1'b1)
				begin
					_a = {32'b0, -a[31:0]};
					_b = {32'b0, -b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, -res[95:64]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
				else
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[95:64]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
			end

			ALU_REMUW:
			begin
				if(b == '0)
					c = {{32{a[31]}}, a[31:0]};
				else
				begin
					_a = {32'b0, a[31:0]};
					_b = {32'b0, b[31:0]};
					valid_div = 1'b1;
					t1 = {32'b0, res[95:64]};
					c = {{32{t1[31]}}, t1[31:0]};
				end
			end

			default: 
			begin
			end
		endcase
	end
	
endmodule

`endif
