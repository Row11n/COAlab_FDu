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


/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;

typedef enum logic [5:0] {
	UNKNOWN, ADDI
} decoded_op_t;

typedef enum logic [4:0] {
	ALU_ADD
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
} execute_data_t;

typedef struct packed {
	u64 pc;
} memory_data_t;

endpackage

`endif
