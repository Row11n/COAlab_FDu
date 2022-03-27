`ifndef __DECODER_SV
`define __DECODER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module decoder
    import common::*;
    import pipes::*;
(
    input u32 raw_instr,
    output control_t ctl,
    output creg_addr_t ra1, ra2,
    output u1 is_im
);

    logic [6:0] f7 = raw_instr[6:0];
    logic [2:0] f3 = raw_instr[14:12];

    always_comb
    begin
        unique case(f7)
        F7_ADDI:
        begin
            unique case(f3)
            F3_ADDI:
            begin
                ctl.op = ADDI;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                is_im = 1'b1;
            end
            default:
            begin
            ctl.op = UNKNOWN;
            is_im = 1'b0;
            end
            endcase
        end
        default:
        begin
        ctl.op = UNKNOWN;
        is_im = 1'b0;
        end
        endcase
    end


endmodule
`endif 