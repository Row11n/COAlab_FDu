`ifndef __MULTIPLIER_SV
`define __MULTIPLIER_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "include/pipes.sv"
`else

`endif

module multiplier_multicycle 
    import common::*;
	import pipes::*;(
    input u1 clk, reset, en,
    input u64 a, b,
    output u64 c,
    output u1 done
);

    enum u1 {INIT, BUSY} state, state_nxt;
    u67 count, count_nxt;
    localparam u67 MUL_DELAY = {2'b0, 1'b1, 64'b0};

    always_ff @(posedge clk) begin
        if(reset) begin
            {state, count} <= '0;
        end else begin
            {state, count} <= {state_nxt, count_nxt};
        end
    end
    assign done = ~en || (state_nxt == INIT); // important!

    always_comb begin
        {state_nxt, count_nxt} = {state, count}; // default
        unique case(state)
            INIT: begin
                if(en) begin
                    state_nxt = BUSY;
                    count_nxt = MUL_DELAY;
                end
            end

            BUSY: begin
               count_nxt = {1'b0, count_nxt[66:1]};
               if (count_nxt == 67'b0) begin
                   state_nxt = INIT;
               end 
            end
        endcase
    end

    logic [128:0] pa, pa_nxt; // need an extra bit [0]
    always_comb begin
        pa_nxt = pa; // default
        unique case(state)
            INIT: begin
                pa_nxt = {64'b0, a, 1'b0};
            end

            BUSY: begin
                if (pa_nxt[1:0] == 2'b01)
                    pa_nxt[128:65] = pa_nxt[128:65] + b;
                else if (pa_nxt[1:0] == 2'b10)
                    pa_nxt[128:65] = pa_nxt[128:65] - b;
                pa_nxt = $signed(pa_nxt) >>> 1'b1;
            end
        endcase
    end
    
    always_ff @(posedge clk) begin
        if(reset) begin
            pa <= '0;
        end else begin
            pa <= pa_nxt;
        end
    end
    assign c = pa[64:1];

endmodule


`endif