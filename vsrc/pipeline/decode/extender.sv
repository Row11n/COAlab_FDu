`ifndef __EXTENDER_SV
`define __EXTENDER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 


module extender
    import common::*;
    import pipes::*;
(
    input u32 raw_instr,
    input control_t ctl,
    input u64 pc,
    input word_t rd2,
    output word_t srcb,
    input forward_data_t forwardE,
    input forward_data_t forwardM,
    input forward_data_t forwardW,
    input creg_addr_t ra2
);

    always_comb
    begin
        unique case(ctl.op)
        
        default:
        begin
        end

        ADDI, XORI, ANDI, ORI, ADDIW, SLTI, SLTIU:
        begin
            srcb = {{52{raw_instr[31]}}, raw_instr[31:20]};
        end

        LUI:
        begin
            srcb = {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};
        end

        AUIPC:
        begin
            srcb = pc + {{32{raw_instr[31]}}, raw_instr[31:12], 12'b0};
        end

        OR, SUB, AND, XOR, ADD, BEQ, SLLW, SRL, SLT, SUBW, SLTU,
        ADDW, SRA, SLL, BNE, BLT, BGE, BLTU, BGEU, SRAW, SRLW, DIVU,
        REMUW, MUL, MULW, DIV, DIVW, REMW, DIVUW, REM, REMU:
        begin
            if(ra2 != '0 && ra2 == forwardE.wa && forwardE.regwrite == 1'b1)
                srcb = forwardE.result;
            else if(ra2 != '0 && ra2 == forwardM.wa && forwardM.regwrite == 1'b1)
                srcb = forwardM.result;
            else if(ra2 != '0 && ra2 == forwardW.wa && forwardW.regwrite == 1'b1)
                srcb = forwardW.result;
            else
                srcb = rd2;
        end

        SD, SH, SB, SW:
        begin
            srcb = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]};
        end

        LD, LWU, LHU, LBU, LH, LW, LB:
        begin
            srcb = {{52{raw_instr[31]}}, raw_instr[31:20]};
        end

        JAL, JALR:
        begin
            srcb = pc + 4;
        end

        SRAI, SLLI, SRAIW, SRLI, SLLIW, SRLIW:
        begin
            srcb = {{58{1'b0}}, raw_instr[25:20]};
        end

        endcase
    end


endmodule
`endif  