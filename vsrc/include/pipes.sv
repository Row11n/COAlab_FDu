 `ifndef __PIPES_SV
`define __PIPES_SV
`ifdef VERILATOR
`include "include/common.sv"
`endif 
package pipes;
	import common::*;	
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;
parameter F7_ADDI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F7_LUI = 7'b0110111;
parameter F7_AUIPC = 7'b0010111;
parameter F7_OR_SUB = 7'b0110011;
parameter F3_OR = 3'b110;
parameter F3_SUB = 3'b000;



/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;
 
typedef enum logic [5:0] {
	UNKNOWN, ADDI, LUI, AUIPC, OR, SUB
} decoded_op_t;

typedef enum logic [4:0] {
	ALU_ADD, ALU_OR, ALU_SUB
} alufunc_t;

typedef struct packed {
	decoded_op_t op;
	alufunc_t alufunc;
	u1 regwrite;
} control_t;

typedef struct packed {
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst; 
	u64 pc;
} decode_data_t;

typedef struct packed {
	u64 pc;
	control_t ctl;
	word_t result_alu;
	creg_addr_t wa;
} execute_data_t;

typedef struct packed {
	u64 pc;
	control_t ctl;
	word_t result;
	creg_addr_t wa;
} memory_data_t;

typedef struct packed {
	word_t resultE;
	word_t resultM;
	creg_addr_t waE;
	creg_addr_t waM;
	u1 regwriteE;
	u1 regwriteM;
} forward_data_t;

endpackage

`endif
