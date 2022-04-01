`ifndef __MEMORY_SV
`define __MEMORY_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
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
    output forward_data_t forwardM
);

    always_latch
    begin
        if(dataE.ctl.memwrite == 1'b1)
        begin
            dreq.valid = 1'b1;
            dreq.strobe = '1;
            dreq.data = dataE.wd;
            dataM.wd = dataE.wd;
        end
        else if(dataE.ctl.memread == 1'b1)
        begin
            dreq.valid = 1'b0;
            dreq.strobe = '0;
            dataM.wd = dresp.data;
        end
        else
        begin
            dreq.valid = 1'b0;
        end
    end
    
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



endmodule
`endif 