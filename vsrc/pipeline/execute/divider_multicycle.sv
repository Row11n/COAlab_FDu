`ifndef __DIVIDER_SV
`define __DIVIDER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module divider_multicycle
    import common::*;
	import pipes::*;(
    input logic clk, reset, valid,
    output logic done,
    input u64 a, b,
    output u128 res // res = {a % b, a / b}
);
    enum u1 { INIT, DOING } state, state_nxt;
    u66 count, count_nxt;
    localparam u66 DIV_DELAY = {1'b0, 1'b1, 64'b0};
    always_ff @(posedge clk) begin
        if (reset) begin
            {state, count} <= '0;
        end else begin
            {state, count} <= {state_nxt, count_nxt};
        end
    end
    assign done = (state_nxt == INIT);
    always_comb begin
        {state_nxt, count_nxt} = {state, count}; // default
        unique case(state)
            INIT: begin
                if (valid) begin
                    state_nxt = DOING;
                    count_nxt = DIV_DELAY;
                end
            end
            DOING: 
            begin
                repeat(4)
                begin
                count_nxt = {1'b0, count_nxt[65:1]};
                    if (count_nxt == '0) 
                    begin
                        state_nxt = INIT;
                    end
                end
            end
        endcase
    end


    u128 p, p_nxt;
    always_comb begin
        p_nxt = p;
        unique case(state)
            INIT: begin
                p_nxt = {64'b0, a};
            end
            DOING: begin
                repeat(4)
                begin
                    p_nxt = {p_nxt[126:0], 1'b0};
                    if (p_nxt[127:64] >= b) 
                    begin
                        p_nxt[127:64] -= b;
                        p_nxt[0] = 1'b1;
                    end
                end
            end
        endcase
    end
    always_ff @(posedge clk) begin
        if (reset) begin
            p <= '0;
        end else begin
            p <= p_nxt;
        end
    end
    assign res = p;
endmodule



`endif 