`ifndef __MULTIPLIER_DSP_SV
`define __MULTIPLIER_DSP_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module multiplier_multicycle_dsp 
    import common::*;
	import pipes::*;(
    input logic clk, reset, valid,
    output logic done,
    input u64 a, b,
    output u64 c // c = a * b
);
    logic [2:0][63:0]p, p_nxt;
    assign p_nxt[0] = a[31:0] * b[31:0];
    assign p_nxt[1] = a[31:0] * b[63:32];
    assign p_nxt[2] = a[63:32] * b[31:0];

    always_ff @(posedge clk) 
    begin
        if (reset) begin
            p <= '0;
        end else begin
            p <= p_nxt;
        end
    end

    logic [2:0][63:0] q;
    assign q[0] = {p[0]};
    assign q[1] = {p[1][31:0], 32'b0};
    assign q[2] = {p[2][31:0], 32'b0};
    assign c = q[0] + q[1] + q[2];

    enum logic {INIT, DOING} state, state_nxt;

    always_ff @(posedge clk) 
    begin
        if (reset) begin
            state <= INIT;
        end else begin
            state <= state_nxt;
        end
    end

    always_comb 
    begin
        state_nxt = state;
        if (state == DOING) 
        begin
            state_nxt = INIT;
        end 
        else if (valid) 
        begin
            state_nxt = DOING;
        end
    end

    assign done = (state_nxt == INIT);
    
endmodule


`endif
