`ifndef __PIPES_SV
`define __PIPES_SV
`ifdef VERILATOR
`include "include/common.sv"
`endif 
package pipes;
	import common::*;	
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;
parameter F7_ADDI_XORI_ANDI_ORI = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ANDI = 3'b111;
parameter F3_ORI = 3'b110;

parameter F7_LUI = 7'b0110111;
parameter F7_AUIPC = 7'b0010111;

parameter F7_OR_SUB_AND_XOR_ADD = 7'b0110011;
parameter F3_OR = 3'b110;
parameter F3_SUB_ADD = 3'b000;
parameter F3_AND = 3'b111;
parameter F3_XOR = 3'b100;
parameter FL7_ADD = 7'b0000000;
parameter FL7_SUB = 7'b0100000;

parameter F7_SD = 7'b0100011;
parameter F3_SD = 3'b011;

parameter F7_LD = 7'b0000011;
parameter F3_LD = 3'b011;

parameter F7_NOP = 7'b0000000;
parameter F3_NOP = 3'b000;
parameter FL7_NOP = 7'b0000000;

parameter F7_BEQ = 7'b1100011;
parameter F3_BEQ = 3'b000;

parameter F7_JAL = 7'b1101111;
parameter F7_JALR = 7'b1100111;
parameter F3_JALR = 3'b000;


/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;
 
typedef enum logic [5:0] {
	UNKNOWN, ADDI, LUI, AUIPC, OR, SUB, XORI, AND, XOR, ADD,
	SD, LD, NOP, BEQ, ANDI, ORI, JAL, JALR
} decoded_op_t;

typedef enum logic [4:0] {
	ALU_ADD, ALU_OR, ALU_SUB, ALU_XOR, ALU_AND, ALU_FUCKING,
	ALU_SUCKING
} alufunc_t;

typedef struct packed {
	decoded_op_t op;
	alufunc_t alufunc;
	u1 regwrite;
	u1 memwrite;
	u1 memread;
	u1 nop_signal;
	u1 branch;
} control_t;

typedef struct packed {
	word_t srca, srcb;
	control_t ctl;
	creg_addr_t dst;
	word_t wd; 
	u64 pc;
} decode_data_t;

typedef struct packed {
	u64 pc;
	control_t ctl;
	word_t result_alu;
	word_t wd;
	creg_addr_t wa;
} execute_data_t;

typedef struct packed {
	u64 pc;
	control_t ctl;
	word_t result_alu;
	word_t wd;
	creg_addr_t wa;
	u1 addr_31;
} memory_data_t;

typedef struct packed {
	word_t result;
	creg_addr_t wa;
	u1 regwrite;
} forward_data_t;

endpackage

`endif
