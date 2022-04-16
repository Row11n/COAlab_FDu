`ifndef __PIPES_SV
`define __PIPES_SV
`ifdef VERILATOR
`include "include/common.sv"
`endif 
package pipes;
	import common::*;	
/* Define instrucion decoding rules here */

// parameter F7_RI = 7'bxxxxxxx;
parameter F7_ADDI_XORI_ANDI_ORI_SRAI_SLLI_SRLI_SLTI_SLTIU = 7'b0010011;
parameter F3_ADDI = 3'b000;
parameter F3_XORI = 3'b100;
parameter F3_ANDI = 3'b111;
parameter F3_ORI = 3'b110;
parameter F3_SRAI_SRLI = 3'b101;
parameter F3_SLLI = 3'b001;
parameter F3_SLTI = 3'b010;
parameter F3_SLTIU = 3'b011;
parameter FL6_SRAI = 6'b010000;
parameter FL6_SRLI = 6'b000000;
parameter FL6_SLLI = 6'b000000;

parameter F7_LUI = 7'b0110111;
parameter F7_AUIPC = 7'b0010111;

parameter F7_OR_SUB_AND_XOR_ADD_SRL_SLT_SLTU_SRA_SLL = 7'b0110011;
parameter F3_OR = 3'b110;
parameter F3_SUB_ADD = 3'b000;
parameter F3_AND = 3'b111;
parameter F3_XOR = 3'b100;
parameter F3_SRL_SRA = 3'b101;
parameter F3_SLT = 3'b010;
parameter F3_SLTU = 3'b011;
parameter F3_SLL = 3'b001;
parameter FL7_SRL = 7'b0000000;
parameter FL7_SRA = 7'b0100000;
parameter FL7_SLTU = 7'b0000000;
parameter FL7_ADD = 7'b0000000;
parameter FL7_SUB = 7'b0100000;
parameter FL7_SLT = 7'b0000000;
parameter FL7_SLL = 7'b0000000;

parameter F7_SD = 7'b0100011;
parameter F3_SD = 3'b011;

parameter F7_LD = 7'b0000011;
parameter F3_LD = 3'b011;

parameter F7_NOP = 7'b0000000;
parameter F3_NOP = 3'b000;
parameter FL7_NOP = 7'b0000000;

parameter F7_BEQ_BNE_BLT_BGE_BLTU = 7'b1100011;
parameter F3_BEQ = 3'b000;
parameter F3_BNE = 3'b001;
parameter F3_BLT = 3'b100;
parameter F3_BGE = 3'b101;
parameter F3_BLTU = 3'b110;
parameter F3_BGEU = 3'b111;

parameter F7_JAL = 7'b1101111;
parameter F7_JALR = 7'b1100111;
parameter F3_JALR = 3'b000;

parameter F7_ADDIW_SRAIW_SLLIW_SRLIW = 7'b0011011;
parameter F3_ADDIW = 3'b000;
parameter F3_SRAIW_SRLIW = 3'b101;
parameter F3_SLLIW = 3'b001;
parameter FL6_SRAIW = 6'b010000;
parameter FL6_SLLIW = 6'b000000;
parameter FL6_SRLIW = 6'b000000;


parameter F7_SLLW_SUBW_SRAW_SRLW_ADDW = 7'b0111011;
parameter F3_SLLW = 3'b001;
parameter F3_SUBW_ADDW = 3'b000;
parameter F3_SRAW_SRLW = 3'b101;
parameter FL7_SLLW = 7'b0000000;
parameter FL7_SUBW = 7'b0100000;
parameter FL7_SRAW = 7'b0100000;
parameter FL7_SRLW = 7'b0000000;
parameter FL7_ADDW = 7'b0000000;



/* Define pipeline structures here */

typedef struct packed {
	u32 raw_instr;
	u64 pc;
} fetch_data_t;
 
typedef enum logic [5:0] {
	UNKNOWN, ADDI, LUI, AUIPC, OR, SUB, XORI, AND, XOR, ADD,
	SD, LD, NOP, BEQ, ANDI, ORI, JAL, JALR, ADDIW, SLLW, SRL,
	SUBW, SRAI, SLT, SRAW, SLTU, SLLI, SRLW, ADDW, SRAIW, SRA,
	SLL, SRLI, SLLIW, BNE, BLT, BGE, BLTU, BGEU, SRLIW, SLTI,
	SLTIU
} decoded_op_t;

typedef enum logic [4:0] {
	ALU_ADD, ALU_OR, ALU_SUB, ALU_XOR, ALU_AND, ALU_FUCKING,
	ALU_SUCKING, ALU_ADDW, ALU_SLLW, ALU_SRL, ALU_SUBW, ALU_SRA,
	ALU_SLT, ALU_SRAW, ALU_SLTU, ALU_SLL, ALU_SRLW
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
