`ifndef __PC_ALU_SV
`define __PC_ALU_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"

`else
`endif 
module pc_alu
    import common::*;
    import pipes::*;
(
    input u64 pc,
    input u32 raw_instr,
    output u64 pcsrc,
    input control_t ctl,
    input u64 reg_data
);
    u64 offset;

    always_comb
    begin
        offset = '0;
        pcsrc = pc;
        unique case(ctl.op)

            default:
            begin
                offset = '0;
                pcsrc = pc;
            end

            BEQ, BNE, BLT, BGE, BLTU, BGEU:
            begin
                offset = {{51{raw_instr[31]}}, raw_instr[31], raw_instr[7],
                    raw_instr[30:25], raw_instr[11:8], 1'b0};
                pcsrc = pc + offset;
            end
          
            
            JAL:
            begin
                offset = {{43{raw_instr[31]}}, raw_instr[31], raw_instr[19:12], raw_instr[20],
                    raw_instr[30:21], 1'b0};
                pcsrc = pc + offset;
            end
            

            JALR:
            begin
                offset = {{52{raw_instr[31]}}, raw_instr[31:20]};
                pcsrc = (reg_data + offset) & {{63{1'b1}}, 1'b0};
            end
            

        endcase
    end

endmodule
`endif