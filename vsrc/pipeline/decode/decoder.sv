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
    output creg_addr_t ra1, ra2
);

    logic [6:0] f7 = raw_instr[6:0];
    logic [2:0] f3 = raw_instr[14:12];
    logic [6:0] fl7 = raw_instr[31:25];

    always_comb
    begin
        unique case(f7)

        F7_ADDI_XORI:
        begin
            unique case(f3)

            F3_ADDI:
            begin
                ctl.op = ADDI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
            end

            F3_XORI:
            begin
                ctl.op = XORI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_XOR;
                ra1 = raw_instr[19:15];
            end

            default:
            begin
            ctl.op = UNKNOWN;
            end
            endcase
        end

        F7_LUI:
        begin
            ctl.op = LUI;
            ctl.memwrite = 1'b0;
            ctl.memread = 1'b0;
            ctl.regwrite = 1'b1;
            ctl.alufunc = ALU_ADD;
            ra1 = 5'b00000;
        end

        F7_AUIPC:
        begin
            ctl.op = AUIPC;
            ctl.memwrite = 1'b0;
            ctl.memread = 1'b0;
            ctl.regwrite = 1'b1;
            ctl.alufunc = ALU_ADD;
            ra1 = 5'b00000;
        end

        F7_OR_SUB_AND_XOR_ADD:
        begin
            unique case(f3)

            F3_OR:
            begin
                ctl.op = OR;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_OR;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_SUB_ADD:
            begin
                unique case(fl7)
                default:
                begin
                end

                FL7_SUB:
                begin
                    ctl.op = SUB;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SUB;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end
                
                FL7_ADD:
                begin
                    ctl.op = ADD;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_ADD;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end


                endcase
            end

            F3_AND:
            begin
                ctl.op = AND;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_AND;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_XOR:
            begin
                ctl.op = XOR;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.alufunc = ALU_XOR;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            default:
            begin
            ctl.op = UNKNOWN;
            end
            endcase
        end

        F7_SD:
            begin
                unique case(f3)
                default:
                begin
                    
                end
                
                F3_SD:
                begin
                    ctl.op = SD;
                    ctl.regwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.memwrite = 1'b1;
                    ctl.alufunc = ALU_ADD;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                endcase
            end

        F7_LD:
            begin
                unique case(f3)
                default:
                begin
                    
                end
                
                F3_LD:
                begin
                    ctl.op = LD;
                    ctl.regwrite = 1'b1;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b1;
                    ctl.alufunc = ALU_ADD;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                endcase
            end

        default:
        begin
        ctl.op = UNKNOWN;
        end
        endcase
    end


endmodule
`endif 