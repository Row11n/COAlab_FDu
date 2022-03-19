`ifndef __EXECUTE_SV
`define __EXECUTE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else
`endif 

module execute
    import common::*;
    import pipes::*;
(
    input decode_data_t dataD,
    output execute_data_t dataE
);
    word_t result_alu;
    always_comb
    begin
        unique case(dataD.ctl.alufunc)
        ALU_ADD:
        begin
            result_alu = dataD.srca + dataD.srcb;
        end
        default
        begin

        end
        endcase
    end

    assign dataE.pc = dataD.pc;
    assign dataE.ctl = dataD.ctl;
    assign dataE.result_alu = result_alu;
    assign dataE.wa = dataD.dst;
    
endmodule
`endif