`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		parameter WORDS_PER_LINE = 16,
		parameter ASSOCIATIVITY = 2,    //2路
		parameter SET_NUM = 8,          //8块

		parameter OFFSET_BITS = $clog2(WORDS_PER_LINE),
		parameter INDEX_BITS = $clog2(SET_NUM),
		parameter TAG_BITS = 64 - INDEX_BITS - OFFSET_BITS - 3
	)(
	input logic clk, reset,

	input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  creq,
    input  cbus_resp_t cresp
);

`ifndef REFERENCE_CACHE
	/* TODO: Lab3 Cache */
    assign dresp = '0;
    assign creq = '0;

    // typedefs
	typedef enum u2 
    {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

    typedef u4 offset_t;
    typedef u3 index_t;
    typedef logic [TAG_BITS-1:0] tag_t;

    typedef struct packed 
    {
        u1 valid;
        u1 dirty;
        tag_t tag;
    } meta_t;

    
    //funtions
    function offset_t get_offset(addr_t addr);
        return addr[3+OFFSET_BITS-1:3];
    endfunction

    function index_t get_index(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS-1:OFFSET_BITS+3];
    endfunction

    function tag_t get_tag(addr_t addr);
        return addr[3+INDEX_BITS+OFFSET_BITS+TAG_BITS-1:3+INDEX_BITS+OFFSET_BITS];
    endfunction

    //cache_set
    for (genvar i = 0; i < SET_NUM; i++) 
    begin : cache_sets

    
    end : cache_sets

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];


    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram_data;
    word_t ram_rdata;

    struct packed {
        logic    en;
        u2 strobe;
        logic [$bits(meta_t)-1:0]  wmeta;
    } ram_meta;
    logic [$bits(meta_t)-1:0]  ram_rmeta;

    always_comb
    unique case (state)
    FETCH: begin
        ram_data.en     = 1;
        ram_data.strobe = 8'b11111111;
        ram_data.wdata  = cresp.data;
    end

    READY: begin
        ram_data.en     = 1;
        ram_data.strobe = req.strobe;
        ram_data.wdata  = req.data;
    end

    default: ram_data = '0;
    endcase

    //data
    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
    ) ram_for_data (
        .clk(clk), .en(ram_data.en),
        .addr(offset),
        .strobe(ram_data.strobe),
        .wdata(ram_data.wdata),
        .rdata(ram_rdata)
    );

    //meta
    RAM_SimpleDualPort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH($bits(meta_t) * ASSOCIATIVITY),
		.BYTE_WIDTH($bits(meta_t)),
		.READ_LATENCY(0)
    ) ram_for_meta (
        .clk(clk), .en(ram_meta.en),
        .raddr(offset),
        .waddr(offset),
        .strobe(ram_meta.strobe),
        .wdata(ram_meta.wdata),
        .rdata(ram_rmeta)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) 
    begin
        unique case (state)
        IDLE: if (dreq.valid) 
        begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) 
        begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: 
        begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) 
        begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end 
    else 
    begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`else

    // typedefs
	typedef enum u2 
    {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

    typedef union packed 
    {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef struct packed 
    {
        u1 valid;
        u1 dirty;
        tag_t tag;
    } meta_t;

    typedef u4 offset_t;
    typedef u3 index_t;
    type tag_t = logic [TAG_BITS-1:0];

    //cache_set
    for (genvar i = 0; i < SET_NUM; i++) 
    begin : cache_sets

    
    end : cache_sets

    // registers
    state_t    state /* verilator public_flat_rd */;
    dbus_req_t req;  // dreq is saved once addr_ok is asserted.
    offset_t   offset;

    // wires
    offset_t start;
    assign start = dreq.addr[6:3];


    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram_data;
    word_t ram_rdata;

    struct packed {
        logic    en;
        u2 strobe;
        logic [$bits(meta_t)-1:0]  wmeta;
    } ram_meta;
    logic [$bits(meta_t)-1:0]  ram_rmeta;

    always_comb
    unique case (state)
    FETCH: begin
        ram_data.en     = 1;
        ram_data.strobe = 8'b11111111;
        ram_data.wdata  = cresp.data;
    end

    READY: begin
        ram_data.en     = 1;
        ram_data.strobe = req.strobe;
        ram_data.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    //data
    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_data (
        .clk(clk), .en(ram_data.en),
        .addr(offset),
        .strobe(ram_data.strobe),
        .wdata(ram_data.wdata),
        .rdata(ram_rdata)
    );

    //meta
    RAM_SimpleDualPort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH($bits(meta_t) * ASSOCIATIVITY),
		.BYTE_WIDTH($bits(meta_t)),
		.READ_LATENCY(0)
    ) ram_meta (
        .clk(clk), .en(ram_meta.en),
        .raddr(offset),
        .waddr(offset),
        .strobe(ram_meta.strobe),
        .wdata(ram_meta.wdata),
        .rdata(ram_rmeta)
    );

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == FLUSH;
    assign creq.is_write = state == FLUSH;
    assign creq.size     = MSIZE8;
    assign creq.addr     = req.addr;
    assign creq.strobe   = 8'b11111111;
    assign creq.data     = ram_rdata;
    assign creq.len      = MLEN16;
	assign creq.burst	 = AXI_BURST_INCR;

    // the FSM
    always_ff @(posedge clk)
    if (~reset) 
    begin
        unique case (state)
        IDLE: if (dreq.valid) 
        begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) 
        begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: 
        begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) 
        begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end 
    else 
    begin
        state <= IDLE;
        {req, offset} <= '0;
    end

`endif

endmodule

`endif
