`ifndef __CORE_SV
`define __CORE_SV
`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/regfile/regfile.sv"
`include "pipeline/decode/decode.sv"
`include "pipeline/decode/decode_reg.sv"
`include "pipeline/fetch/fetch.sv"
`include "pipeline/fetch/fetch_reg.sv"
`include "pipeline/fetch/pc_reg.sv"
`include "pipeline/memory/memory.sv"
`include "pipeline/memory/memory_reg.sv"
`include "pipeline/execute/execute.sv"
`include "pipeline/execute/execute_reg.sv"
`include "pipeline/writeback/writeback.sv"


`else

`endif

module core 
	import common::*;
	import pipes::*;
(
	input logic clk, reset,
	output ibus_req_t  ireq,
	input  ibus_resp_t iresp,
	output dbus_req_t  dreq,
	input  dbus_resp_t dresp
);
	/* TODO: Add your pipeline here. */
	u64 pc, pc_nxt, pc_result;
	u32 raw_instr;
	fetch_data_t dataF;
	fetch_data_t dataF_nxt;
	decode_data_t dataD;
	decode_data_t dataD_nxt;
	execute_data_t dataE;
	execute_data_t dataE_nxt;
	memory_data_t dataM;
	memory_data_t dataM_nxt;
	forward_data_t forwardE;
	forward_data_t forwardM;
	forward_data_t forwardW;
	u1 stall;
	u1 stallM;
	u1 stallI;
	u1 pc_valid;
	creg_addr_t ra1, ra2;
    word_t rd1, rd2;
	u1 regwrite;
	creg_addr_t wa;
	word_t result;
	u1 jump;
	u64 pcsrc;
	u1 skip;


	pc_reg pc_reg
	(
		.clk(clk),
		.reset(reset),
		.pc(pc),
		.stall(stall),
		.jump(jump),
		.pcsrc(pcsrc),
		.stallM(stallM),
		.stallI(stallI)
	);

	fetch fetch
	(
		.dataF(dataF),
		.raw_instr(raw_instr),
		.pc(pc),
		.ireq(ireq),
		.iresp(iresp),
		.stallI(stallI)
	);

	fetch_reg fetch_reg
	(
		.clk(clk),
		.reset(reset),
		.dataF(dataF),
		.dataF_nxt(dataF_nxt),
		.stall(stall),
		.jump(jump),
		.stallM(stallM)
	);

	decode decode
	(
		.dataF(dataF_nxt),
		.dataD(dataD),
		.ra1(ra1),
		.ra2(ra2),
		.rd1(rd1),
		.rd2(rd2),
		.forwardE(forwardE),
		.forwardM(forwardM),
		.forwardW(forwardW),
		.stall(stall),
		.jump(jump),
		.pcsrc(pcsrc)
	);

	decode_reg decode_reg
	(
		.clk(clk),
		.reset(reset),
		.dataD(dataD),
		.dataD_nxt(dataD_nxt),
		.stallM(stallM)
	);

	execute execute
	(
		.dataD(dataD_nxt),
		.dataE(dataE),
		.forwardE(forwardE)
	);

	execute_reg execute_reg
	(
		.clk(clk),
		.reset(reset),
		.dataE(dataE),
		.dataE_nxt(dataE_nxt),
		.stallM(stallM)
	);

	memory memory
	(
		.dataE(dataE_nxt),
		.dataM(dataM),
		.dreq(dreq),
		.dresp(dresp),
		.forwardM(forwardM),
		.stallM(stallM)
	);

	memory_reg memory_reg
	(
		.clk(clk),
		.reset(reset),
		.dataM(dataM),
		.dataM_nxt(dataM_nxt),
		.stallM(stallM)
	);

	writeback writeback
	(
		.dataM(dataM_nxt),
		.regwrite(regwrite),
		.wa(wa),
		.result(result),
		.forwardW(forwardW),
		.pc_result(pc_result),
		.pc_valid(pc_valid),
		.skip(skip)
	);

	regfile regfile(
		.clk, .reset,
		.ra1(ra1),
		.ra2(ra2),
		.rd1(rd1),
		.rd2(rd2),
		.wvalid(regwrite),
		.wa(wa),
		.wd(result)
	);

`ifdef VERILATOR
	DifftestInstrCommit DifftestInstrCommit(
		.clock              (clk),
		.coreid             (0),
		.index              (0),
		.valid              (pc_valid),
		.pc                 (pc_result),
		.instr              (0),
		.skip               (skip),
		.isRVC              (0),
		.scFailed           (0),
		.wen                (regwrite),
		.wdest              ({3'b0,wa}),
		.wdata              (result)
	);
	      
	DifftestArchIntRegState DifftestArchIntRegState (
		.clock              (clk),
		.coreid             (0),
		.gpr_0              (regfile.regs_nxt[0]),
		.gpr_1              (regfile.regs_nxt[1]),
		.gpr_2              (regfile.regs_nxt[2]),
		.gpr_3              (regfile.regs_nxt[3]),
		.gpr_4              (regfile.regs_nxt[4]),
		.gpr_5              (regfile.regs_nxt[5]),
		.gpr_6              (regfile.regs_nxt[6]),
		.gpr_7              (regfile.regs_nxt[7]),
		.gpr_8              (regfile.regs_nxt[8]),
		.gpr_9              (regfile.regs_nxt[9]),
		.gpr_10             (regfile.regs_nxt[10]),
		.gpr_11             (regfile.regs_nxt[11]),
		.gpr_12             (regfile.regs_nxt[12]),
		.gpr_13             (regfile.regs_nxt[13]),
		.gpr_14             (regfile.regs_nxt[14]),
		.gpr_15             (regfile.regs_nxt[15]),
		.gpr_16             (regfile.regs_nxt[16]),
		.gpr_17             (regfile.regs_nxt[17]),
		.gpr_18             (regfile.regs_nxt[18]),
		.gpr_19             (regfile.regs_nxt[19]),
		.gpr_20             (regfile.regs_nxt[20]),
		.gpr_21             (regfile.regs_nxt[21]),
		.gpr_22             (regfile.regs_nxt[22]),
		.gpr_23             (regfile.regs_nxt[23]),
		.gpr_24             (regfile.regs_nxt[24]),
		.gpr_25             (regfile.regs_nxt[25]),
		.gpr_26             (regfile.regs_nxt[26]),
		.gpr_27             (regfile.regs_nxt[27]),
		.gpr_28             (regfile.regs_nxt[28]),
		.gpr_29             (regfile.regs_nxt[29]),
		.gpr_30             (regfile.regs_nxt[30]),
		.gpr_31             (regfile.regs_nxt[31])
	);
	      
	DifftestTrapEvent DifftestTrapEvent(
		.clock              (clk),
		.coreid             (0),
		.valid              (0),
		.code               (0),
		.pc                 (0),
		.cycleCnt           (0),
		.instrCnt           (0)
	);
	      
	DifftestCSRState DifftestCSRState(
		.clock              (clk),
		.coreid             (0),
		.priviledgeMode     (3),
		.mstatus            (0),
		.sstatus            (0),
		.mepc               (0),
		.sepc               (0),
		.mtval              (0),
		.stval              (0),
		.mtvec              (0),
		.stvec              (0),
		.mcause             (0),
		.scause             (0),
		.satp               (0),
		.mip                (0),
		.mie                (0),
		.mscratch           (0),
		.sscratch           (0),
		.mideleg            (0),
		.medeleg            (0)
	      );
	      
	DifftestArchFpRegState DifftestArchFpRegState(
		.clock              (clk),
		.coreid             (0),
		.fpr_0              (0),
		.fpr_1              (0),
		.fpr_2              (0),
		.fpr_3              (0),
		.fpr_4              (0),
		.fpr_5              (0),
		.fpr_6              (0),
		.fpr_7              (0),
		.fpr_8              (0),
		.fpr_9              (0),
		.fpr_10             (0),
		.fpr_11             (0),
		.fpr_12             (0),
		.fpr_13             (0),
		.fpr_14             (0),
		.fpr_15             (0),
		.fpr_16             (0),
		.fpr_17             (0),
		.fpr_18             (0),
		.fpr_19             (0),
		.fpr_20             (0),
		.fpr_21             (0),
		.fpr_22             (0),
		.fpr_23             (0),
		.fpr_24             (0),
		.fpr_25             (0),
		.fpr_26             (0),
		.fpr_27             (0),
		.fpr_28             (0),
		.fpr_29             (0),
		.fpr_30             (0),
		.fpr_31             (0)
	);
	
`endif
endmodule
`endif