`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`include "pipeline/memory/writedata.sv"
`include "pipeline/memory/readdata.sv"
`else
`endif 

module memory
    import common::*;
    import pipes::*;
(
    input execute_data_t dataE,
    output memory_data_t dataM,
    output dbus_req_t dreq,
    input dbus_resp_t dresp,
    output forward_data_t forwardM,
    output u1 stallM
);

    msize_t msize;
    u1 mem_unsigned;
    strobe_t strobe;
    u64 wd;

    always_comb
    begin
        unique case(dataE.ctl.op)
        default:
        begin
            msize = MSIZE8;
            mem_unsigned = 1'b0;
        end

        SD, LD: 
        begin
            msize = MSIZE8;
            mem_unsigned = 1'b0;
        end

        SW, LW:
        begin
            msize = MSIZE4;
            mem_unsigned = 1'b0;
        end

        SH, LH:
        begin
            msize = MSIZE2;
            mem_unsigned = 1'b0;
        end

        SB, LB:
        begin
            msize = MSIZE1;
            mem_unsigned = 1'b0;
        end

        LWU:
        begin
            msize = MSIZE4;
            mem_unsigned = 1'b1;
        end

        LHU:
        begin
            msize = MSIZE2;
            mem_unsigned = 1'b1;
        end

        LBU:
        begin
            msize = MSIZE1;
            mem_unsigned = 1'b1;
        end

        endcase
    end

    always_comb
    begin
        if(dataE.ctl.memwrite == 1'b1)
        begin
            dataM.wd = dreq.data;
        end
        else
        begin
            dataM.wd = wd;
        end
    end

    always_comb
    begin
        if(dataE.ctl.memwrite == 1'b1)
        begin
            dreq.valid = 1'b1;
            dreq.strobe = strobe;
        end
        else if(dataE.ctl.memread == 1'b1)
        begin
            dreq.valid = 1'b1;
            dreq.strobe = '0;
        end
        else
        begin
            dreq.valid = 1'b0;
            dreq.strobe = '0;
        end
    end

    writedata writedata
    (
        .addr(dataE.result_alu[2:0]),
        ._wd(dataE.wd),
        .msize(msize),
        .wd(dreq.data),
        .strobe(strobe)
    );

    readdata readdata
    (
        ._rd(dresp.data),
        .rd(wd),
        .addr(dataE.result_alu[2:0]),
        .msize(msize),
        .mem_unsigned(mem_unsigned)
    );
    
    assign dataM.addr_31 = dreq.addr[31];
    assign dreq.addr = dataE.result_alu;
    assign dataM.pc = dataE.pc;
    assign dataM.ctl = dataE.ctl;
    assign dataM.result_alu = dataE.result_alu;

    assign dataM.wa = dataE.wa;

    assign forwardM.wa = dataM.wa;
    assign forwardM.regwrite = dataM.ctl.regwrite;

    always_comb
    begin
        if(dataM.ctl.memwrite == 1'b1 || dataM.ctl.memread == 1'b1) 
        begin
            forwardM.result = dataM.wd;
        end
        else
        begin
            forwardM.result = dataM.result_alu;
        end
    end

    assign stallM = dreq.valid && ~dresp.data_ok;

endmodule
`endif 