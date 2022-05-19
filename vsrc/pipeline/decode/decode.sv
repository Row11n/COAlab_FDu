`ifndef __DECODE_SV
`define __DECODE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/decode/decoder.sv"
`include "pipeline/decode/extender.sv"
`include "pipeline/decode/pc_alu.sv"
`else
`endif 

module decode
    import common::*;
    import pipes::*;
(
    input fetch_data_t dataF,
    output decode_data_t dataD,
    output creg_addr_t ra1, ra2,
    input word_t rd1, rd2,
    input forward_data_t forwardE,
    input forward_data_t forwardM,
    input forward_data_t forwardW,
    output u1 stall,
    output u1 jump,
    output u64 pcsrc,
    output u1 is_ls
);
    control_t ctl;
    decoder decoder
    (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .ra1(ra1),
        .ra2(ra2)
    );

    assign is_ls = ctl.memread | ctl.memwrite;
    assign dataD.ctl = ctl;
    assign dataD.dst = dataF.raw_instr[11:7];



    //wd's forward-test
    always_comb
    begin
        if(ra2 != '0 && ra2 == forwardE.wa && forwardE.regwrite == 1'b1)
            dataD.wd = forwardE.result;
        else if(ra2 != '0 && ra2 == forwardM.wa && forwardM.regwrite == 1'b1)
            dataD.wd = forwardM.result;
        else if(ra2 != '0 && ra2 == forwardW.wa && forwardW.regwrite == 1'b1)
            dataD.wd = forwardW.result;
        else
            dataD.wd = rd2;
    end

    //scra
    always_comb
    begin
        if(ra1 != '0 && ra1 == forwardE.wa && forwardE.regwrite == 1'b1)
            dataD.srca = forwardE.result;
        else if(ra1 != '0 && ra1 == forwardM.wa && forwardM.regwrite == 1'b1)
            dataD.srca = forwardM.result;
        else if(ra1 != '0 && ra1 == forwardW.wa && forwardW.regwrite == 1'b1)
            dataD.srca = forwardW.result;
        else
            dataD.srca = rd1;
    end

    //scrb
    extender extender
    (
        .raw_instr(dataF.raw_instr),
        .ctl(ctl),
        .pc(dataF.pc),
        .rd2(rd2),
        .srcb(dataD.srcb),
        .forwardE(forwardE),
		.forwardM(forwardM),
		.forwardW(forwardW),
        .ra2(ra2)
    );
    assign dataD.pc = dataF.pc;

    //ifstall
    always_comb
    begin
        //if(ctl.memread == 1'b1 && ctl.regwrite == 1'b1)
        //    stall = 1'b1;
        //else
            stall = 1'b0;
    end

    //pcsrc_compute
    pc_alu pc_alu
    (
        .pc(dataF.pc),
        .raw_instr(dataF.raw_instr),
        .pcsrc(pcsrc),
        .ctl(ctl),
        .reg_data(dataD.srca)
    );

    //ifjump
    always_comb
    begin
        jump = 1'b0;
        if(ctl.branch)
        begin
            unique case(ctl.op)
            
            default:
            begin
                
            end

            BEQ:
            begin
                if(dataD.srca == dataD.srcb)
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            BNE:
            begin
                if(dataD.srca != dataD.srcb)
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            BLT:
            begin
                if($signed(dataD.srca) < $signed(dataD.srcb))
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            BGE:
            begin
                if($signed(dataD.srca) >= $signed(dataD.srcb))
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            BLTU:
            begin
                if(dataD.srca < dataD.srcb)
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            BGEU:
            begin
                if(dataD.srca >= dataD.srcb)
                begin
                    jump = 1'b1;
                end
                else
                    jump = 1'b0;
            end

            JAL, JALR:
            begin
                jump = 1'b1;
            end

            endcase
        end
        else
        begin
            jump = 1'b0;
        end
    end


endmodule
`endif 