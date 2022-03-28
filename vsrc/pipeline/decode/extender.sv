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
    input forward_data_t forward,
    input creg_addr_t ra2
);

    always_comb
    begin
        unique case(ctl.op)
        
        default:
        begin
        end

        ADDI, XORI:
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

        OR, SUB, AND, XOR, ADD:
        begin
            if(ra2 != '0 && ra2 == forward.waE && forward.regwriteE == 1'b1)
                srcb = forward.resultE;
            else if(ra2 != '0 && ra2 == forward.waM && forward.regwriteM == 1'b1)
                srcb = forward.resultM;
            else if(ra2 != '0 && ra2 == forward.waW && forward.regwriteW == 1'b1)
                srcb = forward.resultW;
            else
                srcb = rd2;
        end

        SD:
        begin
            srcb = {{52{raw_instr[31]}}, raw_instr[31:25], raw_instr[11:7]};
        end

        LD:
        begin
            srcb = {{52{raw_instr[31]}}, raw_instr[31:20]};
        end

        endcase
    end


endmodule
`endif  