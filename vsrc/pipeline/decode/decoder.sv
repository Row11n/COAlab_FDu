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
    logic [5:0] fl6 = raw_instr[31:26];

    always_comb
    begin
    ctl.memwrite = 1'b0;
    ctl.memread = 1'b0;
    ctl.regwrite = 1'b0;
    ctl.nop_signal = 1'b0;
    ctl.branch = 1'b0;
        unique case(f7)

        F7_NOP:
        begin
            unique case(f3)
                default:
                begin
                    
                end

                F3_NOP:
                begin
                    unique case(fl7)
                    default:
                    begin
                        
                    end

                    FL7_NOP:
                    begin
                        ctl.op = NOP;
                        ctl.nop_signal = 1'b1;      
                    end
                    endcase

                end
            endcase
        end

        F7_ADDI_XORI_ANDI_ORI_SRAI_SLLI_SRLI_SLTI_SLTIU:
        begin
            unique case(f3)

            F3_SLLI:
            begin
                unique case(fl6)
                default:
                begin
                    
                end 

                FL6_SLLI:
                begin
                    ctl.op = SLLI;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SLL;
                    ra1 = raw_instr[19:15];
                end
                endcase
            end

            F3_SLTI:
            begin
                ctl.op = SLTI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_SLT;
                ra1 = raw_instr[19:15];
            end

            F3_SLTIU:
            begin
                ctl.op = SLTI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_SLTU;
                ra1 = raw_instr[19:15];
            end

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

            F3_ANDI:
            begin
                ctl.op = ANDI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_AND;
                ra1 = raw_instr[19:15];
            end

            F3_ORI:
            begin
                ctl.op = ORI;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.regwrite = 1'b1;
                ctl.alufunc = ALU_OR;
                ra1 = raw_instr[19:15];
            end

            F3_SRAI_SRLI:
            begin
                unique case(fl6)
                default:
                begin
                    
                end 

                FL6_SRAI:
                begin
                    ctl.op = SRAI;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRA;
                    ra1 = raw_instr[19:15];
                end

                FL6_SRLI:
                begin
                    ctl.op = SRLI;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRL;
                    ra1 = raw_instr[19:15];
                end
                endcase
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

        F7_OR_SUB_AND_XOR_ADD_SRL_SLT_SLTU_SRA_SLL:
        begin
            unique case(f3)

            F3_SLTU:
            begin
                unique case(fl7)
                default:
                begin
                    
                end

                FL7_SLTU:
                begin
                    ctl.op = SLTU;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SLTU;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end
                endcase
            end

            F3_SLT:
            begin
                unique case(fl7)
                default:
                begin
                    
                end

                FL7_SLT:
                begin
                    ctl.op = SLT;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SLT;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end
                endcase
            end

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

            F3_SRL_SRA:
            begin
                unique case(fl7)
                default:
                begin
                end

                FL7_SRL:
                begin
                    ctl.op = SRL;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRL;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                FL7_SRA:
                begin
                    ctl.op = SRA;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRA;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                endcase
            end

            F3_SLL:
            begin
                unique case(fl7)
                default:
                begin
                end

                FL7_SLL:
                begin
                    ctl.op = SLL;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SLL;
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

        F7_SD_SH_SB_SW:
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

            F3_SH:
            begin
                ctl.op = SH;
                ctl.regwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.memwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_SB:
            begin
                ctl.op = SB;
                ctl.regwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.memwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_SW:
            begin
                ctl.op = SW;
                ctl.regwrite = 1'b0;
                ctl.memread = 1'b0;
                ctl.memwrite = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            endcase
        end

        F7_LD_LWU_LHU_LBU_LH_LB_LW:
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

            F3_LH:
            begin
                ctl.op = LH;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_LW:
            begin
                ctl.op = LW;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_LB:
            begin
                ctl.op = LB;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_LWU:
            begin
                ctl.op = LWU;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_LHU:
            begin
                ctl.op = LHU;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_LBU:
            begin
                ctl.op = LBU;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.memread = 1'b1;
                ctl.alufunc = ALU_ADD;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            endcase
        end

        F7_BEQ_BNE_BLT_BGE_BLTU_BGEU:
        begin
            unique case(f3)

            default:
            begin
                
            end

            F3_BEQ:
            begin
                ctl.op = BEQ;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_BNE:
            begin
                ctl.op = BNE;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_BLT:
            begin
                ctl.op = BLT;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_BGE:
            begin
                ctl.op = BGE;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_BLTU:
            begin
                ctl.op = BLTU;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            F3_BGEU:
            begin
                ctl.op = BGEU;
                ctl.regwrite = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_FUCKING;
                ra1 = raw_instr[19:15];
                ra2 = raw_instr[24:20];
            end

            endcase
        end

        F7_JAL:
        begin
            ctl.op = JAL;
            ctl.regwrite = 1'b1;
            ctl.memwrite = 1'b0;
            ctl.branch = 1'b1;
            ctl.memread = 1'b0;
            ctl.alufunc = ALU_SUCKING;
        end

        F7_JALR:
        begin
            unique case(f3)

            default:
            begin
                
            end

            F3_JALR:
            begin
                ctl.op = JALR;
                ctl.regwrite = 1'b1;
                ctl.memwrite = 1'b0;
                ctl.branch = 1'b1;
                ctl.memread = 1'b0;
                ctl.alufunc = ALU_SUCKING;
                ra1 = raw_instr[19:15];
            end
            endcase
        end

        F7_ADDIW_SRAIW_SLLIW_SRLIW:
        begin
            unique case(f3)
            default:
            begin
                
            end
            
            F3_ADDIW:
            begin
                ctl.op = ADDIW;
                ctl.regwrite = 1'b1;
                ctl.memread = 1'b0;
                ctl.memwrite = 1'b0;
                ctl.alufunc = ALU_ADDW;
                ra1 = raw_instr[19:15];
            end

            F3_SRAIW_SRLIW:
            begin
                unique case(fl6)
                default:
                begin
                    
                end 

                FL6_SRAIW:
                begin
                    ctl.op = SRAIW;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRAW;
                    ra1 = raw_instr[19:15];
                end

                FL6_SRLIW:
                begin
                    ctl.op = SRLIW;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SRLW;
                    ra1 = raw_instr[19:15];
                end

                endcase
            end

            F3_SLLIW:
            begin
                unique case(fl6)
                default:
                begin
                    
                end 

                FL6_SLLIW:
                begin
                    ctl.op = SLLIW;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SLLW;
                    ra1 = raw_instr[19:15];
                end
                endcase
            end

            endcase
        end

        F7_SLLW_SUBW_SRAW_SRLW_ADDW:
        begin
            unique case(f3)
            
            default:
            begin
                
            end

            F3_SRAW_SRLW:
            begin
                unique case(fl7)
                default:
                begin
                    
                end

                FL7_SRAW:
                begin
                    ctl.op = SRAW;
                    ctl.regwrite = 1'b1;
                    ctl.memread = 1'b0;
                    ctl.memwrite = 1'b0;
                    ctl.alufunc = ALU_SRAW;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                FL7_SRLW:
                begin
                    ctl.op = SRLW;
                    ctl.regwrite = 1'b1;
                    ctl.memread = 1'b0;
                    ctl.memwrite = 1'b0;
                    ctl.alufunc = ALU_SRLW;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                endcase        
            end
            
            F3_SLLW:
            begin
                unique case(fl7)
                default:
                begin
                    
                end

                FL7_SLLW:
                begin
                    ctl.op = SLLW;
                    ctl.regwrite = 1'b1;
                    ctl.memread = 1'b0;
                    ctl.memwrite = 1'b0;
                    ctl.alufunc = ALU_SLLW;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end
                endcase  
            end

            F3_SUBW_ADDW:
            begin
                unique case(fl7)
                
                default:
                begin
                    
                end

                FL7_SUBW:
                begin
                    ctl.op = SUBW;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_SUBW;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                FL7_ADDW:
                begin
                    ctl.op = ADDW;
                    ctl.memwrite = 1'b0;
                    ctl.memread = 1'b0;
                    ctl.regwrite = 1'b1;
                    ctl.alufunc = ALU_ADDW;
                    ra1 = raw_instr[19:15];
                    ra2 = raw_instr[24:20];
                end

                endcase
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