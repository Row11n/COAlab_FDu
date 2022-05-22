`ifndef __DCACHE_SV
`define __DCACHE_SV

`ifdef VERILATOR
`include "include/common.sv"
`include "ram/RAM_SinglePort.sv"
`include "ram/RAM_SimpleDualPort.sv"
/* You should not add any additional includes in this file */
`endif

module DCache 
	import common::*; #(
		/* You can modify this part to support more parameters */
		/* e.g. OFFSET_BITS, INDEX_BITS, TAG_BITS */
		parameter WORDS_PER_LINE = 16,
		parameter ASSOCIATIVITY = 2,    //2路
		parameter SET_NUM = 8,          //8块
		parameter LINE_NUM = 16,          //共16线

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

    // typedefs
	typedef enum u2 
    {
		INIT,
        FETCH,
        WRITEBACK,
        UNCACHED
	} state_t;

    typedef logic [TAG_BITS-1:0]  tag_t;

    typedef struct packed 
    {
        u1 valid;
        u1 dirty;
        tag_t tag;
    } meta_t;

    typedef u4 offset_t;
    typedef u3 index_t;
    
    typedef logic [$bits(meta_t)+$bits(meta_t)-1:0] metaset_t;

    // registers
    state_t    state;
    offset_t   offset;
    offset_t   start;
    index_t    index;
    index_t    index_reset;
    tag_t      req_tag;
    tag_t      tag_test0;
    tag_t      tag_test1;
    u1         valid_test0;
    u1         valid_test1;
    u1         dirty_test0;
    u1         dirty_test1;
    dbus_req_t req;
    u1 hit;
    u8 addr_data;
    u1 index_line;
    u1 dirty_flag;
    u1 line_saved;
    u1 line_saved_for_writeback;

    u1 random;

    assign tag_test0 = get_tag_line0(ram_rmeta);
    assign tag_test1 = get_tag_line1(ram_rmeta);
    assign valid_test0 = get_valid_line0(ram_rmeta);
    assign valid_test1 = get_valid_line1(ram_rmeta);
    assign dirty_test0 = get_dirty_line0(ram_rmeta);
    assign dirty_test1 = get_dirty_line1(ram_rmeta);


    // wires
    assign start = get_offset(dreq.addr);
    assign index = reset ? index_reset : get_index(dreq.addr);
    assign req_tag = get_tag(dreq.addr);
    assign addr_data = (state == FETCH || state == WRITEBACK) ? {index, line_saved, offset} : {index, index_line, start};


    // the RAM
    struct packed {
        logic    en;
        strobe_t strobe;
        word_t   wdata;
    } ram_data;
    word_t ram_rdata;

    struct packed {
        logic en;
        u2  strobe;
        metaset_t wmeta;
    } ram_meta;
    metaset_t ram_rmeta;

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

    function u1 get_valid_line0(metaset_t metaset);
        return metaset[111];
    endfunction

    function u1 get_valid_line1(metaset_t metaset);
        return metaset[55];
    endfunction

    function u1 get_dirty_line0(metaset_t metaset);
        return metaset[110];
    endfunction

    function u1 get_dirty_line1(metaset_t metaset);
        return metaset[54];
    endfunction

    function u54 get_tag_line0(metaset_t metaset);
        return metaset[109:56];
    endfunction

    function u54 get_tag_line1(metaset_t metaset);
        return metaset[53:0];
    endfunction


    always_comb
    begin
        hit = 0;
        ram_meta.en = 0;
        index_line = 0;
        ram_data.en = 0;
        dirty_flag = 0;
        ram_data.wdata = '0;
        if(reset)
        begin
            ram_meta.wmeta = '0;
            ram_meta.en = 1;
            ram_meta.strobe = 2'b11;
        end
        else
        begin
            unique case (state)
            INIT: 
            begin
                if(dreq.valid)
                begin
                    if(|dreq.strobe) //写请求
                    begin
                        if(req_tag == get_tag_line0(ram_rmeta))
                        begin
                            if(get_valid_line0(ram_rmeta) == '0)
                            begin
                                index_line = 0;
                                dirty_flag = 1;
                                hit = 0;
                            end
                            else
                            begin
                                index_line = 0;
                                hit = 1;

                                ram_data.en = 1;
                                ram_data.wdata = dreq.data;
                                ram_data.strobe = dreq.strobe;

                                ram_meta.strobe = 2'b10;
                                ram_meta.wmeta = {1'b1, 1'b1, req_tag, 56'b0};
                                ram_meta.en = 1;
                            end
                        end
                        else if(req_tag == get_tag_line1(ram_rmeta))
                        begin
                            if(get_valid_line1(ram_rmeta) == '0)
                            begin
                                index_line = 1;
                                dirty_flag = 1;
                                hit = 0;
                            end 
                            else 
                            begin
                                index_line = 1;
                                hit = 1;

                                ram_data.en = 1;
                                ram_data.wdata = dreq.data;
                                ram_data.strobe = dreq.strobe;

                                ram_meta.strobe = 2'b01;
                                ram_meta.wmeta = {56'b0, 1'b1, 1'b1, req_tag};
                                ram_meta.en = 1;
                            end
                        end
                        else
                        begin
                            if(get_valid_line0(ram_rmeta) == '0)
                                index_line = 0; 
                            else if(get_valid_line1(ram_rmeta) == '0)
                                index_line = 1;
                            else
                                index_line = random;
                            
                            if(hit == 0)
                            begin
                                if(index_line == 0)
                                begin
                                    if(get_dirty_line0(ram_rmeta) == 1)
                                        dirty_flag = 1;
                                end
                                else
                                begin
                                    if(get_dirty_line1(ram_rmeta) == 1)
                                        dirty_flag = 1;
                                end 
                            end
                        end
                    end
                    else //读请求
                    begin
                        ram_meta.en = 0;
                        ram_meta.strobe = 2'b11;
                        ram_meta.wmeta = '0;

                        if(req_tag == get_tag_line0(ram_rmeta))
                        begin
                            if(get_valid_line0(ram_rmeta) == '1)
                            begin
                                hit = 1;
                                index_line = 0;
                            end
                            else
                            begin
                                hit = 0;
                                index_line = 0;
                                dirty_flag = 1;
                            end
                        end
                        else if(req_tag == get_tag_line1(ram_rmeta))
                        begin
                            if(get_valid_line1(ram_rmeta) == '1)
                            begin
                                hit = 1;
                                index_line = 1;
                            end
                            else
                            begin
                                hit = 0;
                                index_line = 1;
                                dirty_flag = 1;
                            end
                        end
                        else
                            hit = 0;

                        if(hit == 0)
                        begin
                            if(get_valid_line0(ram_rmeta) == '0)
                                index_line = 0;
                            else if(get_valid_line1(ram_rmeta) == '0)
                                index_line = 1;
                            else
                                index_line = random;
                            if(index_line == 0 && get_dirty_line0(ram_rmeta) == 1)
                                dirty_flag = 1;
                            if(index_line == 1 && get_dirty_line1(ram_rmeta) == 1)
                                dirty_flag = 1;
                        end

                        // if(get_valid_line0(ram_rmeta) == '0 && get_valid_line1(ram_rmeta) == '0)  
                        // begin
                        //     hit = 0;
                        // end
                        // else if(get_valid_line0(ram_rmeta) == '1 || get_valid_line1(ram_rmeta) == '1)
                        // begin
                        //     if(get_valid_line0(ram_rmeta) == 1'b1)
                        //     begin
                        //         if(req_tag == get_tag_line0(ram_rmeta))
                        //         begin
                        //             hit = 1;
                        //             index_line = 0;
                        //         end
                        //     end

                        //     if(get_valid_line1(ram_rmeta) == 1'b1)
                        //     begin
                        //         if(req_tag == get_tag_line1(ram_rmeta))
                        //         begin
                        //             hit = 1;
                        //             index_line = 1;
                        //         end
                        //     end

                            // if(hit == 0)
                            // begin
                            //     if(index_line == 0 && get_dirty_line0(ram_rmeta) == 1)
                            //         dirty_flag = 1;
                            //     if(index_line == 1 && get_dirty_line1(ram_rmeta) == 1)
                            //         dirty_flag = 1;
                            // end
                        // end
                        // else
                        // begin
                        //     hit = 0;
                        //     if(index_line == 0 && get_dirty_line0(ram_rmeta) == 1)
                        //         dirty_flag = 1;
                        //     if(index_line == 1 && get_dirty_line1(ram_rmeta) == 1)
                        //         dirty_flag = 1;
                        // end
                    end
                end
            end

            FETCH: 
            begin
                if(cresp.ready) //写入数据
                begin
                    ram_data.en = 1;
                    ram_data.strobe = '1;
                    ram_data.wdata = cresp.data;
                end
                if(cresp.last) //在最后一个回合写meta
                begin
                    ram_meta.en = 1;
                    if(line_saved == 0)
                    begin
                        ram_meta.strobe = 2'b10;
                        ram_meta.wmeta = {1'b1, 1'b0, req_tag, 56'b0};
                    end
                        
                    else
                    begin
                        ram_meta.strobe = 2'b01;
                        ram_meta.wmeta = {56'b0, 1'b1, 1'b0, req_tag};
                    end
                end
            end

            WRITEBACK: 
            begin
                if(cresp.last) //在最后一个回合写meta
                begin
                    ram_meta.en = 1;
                    if(line_saved == 0)
                    begin
                        ram_meta.strobe = 2'b10;
                        ram_meta.wmeta = {1'b0, 1'b0, req_tag, 56'b0};
                    end
                        
                    else
                    begin
                        ram_meta.strobe = 2'b01;
                        ram_meta.wmeta = {56'b0, 1'b0, 1'b0, req_tag};
                    end
                end
            end

            default:
            begin
                
            end
            endcase
        end
    end

    //data
    RAM_SinglePort #(
		.ADDR_WIDTH(8),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
    ) ram_for_data (
        .clk(clk), .en(ram_data.en),
        .addr(addr_data),
        .strobe(ram_data.strobe),
        .wdata(ram_data.wdata),
        .rdata(ram_rdata)
    );

    //meta
    RAM_SimpleDualPort #(
		.ADDR_WIDTH(3),
		.DATA_WIDTH($bits(meta_t) * ASSOCIATIVITY),
		.BYTE_WIDTH($bits(meta_t)),
		.READ_LATENCY(0)
    ) ram_for_meta (
        .clk(clk), .en(ram_meta.en),
        .raddr(index),
        .waddr(index),
        .strobe(ram_meta.strobe),
        .wdata(ram_meta.wmeta),
        .rdata(ram_rmeta)
    );

    // DBus driver
    assign dresp.addr_ok = state == INIT;
    assign dresp.data_ok = ((state == INIT) && hit) || (state == UNCACHED && cresp.last);
    assign dresp.data    = (state == UNCACHED) ? cresp.data : ram_rdata;

    // CBus driver
    assign creq.valid    = state == FETCH || state == WRITEBACK || state == UNCACHED;
    assign creq.is_write = (state == WRITEBACK) || (state == UNCACHED && (|dreq.strobe));
    assign creq.size     = (state == UNCACHED) ? dreq.size : MSIZE8;
    assign creq.strobe   = (state == UNCACHED) ? dreq.strobe : 8'b11111111;
    assign creq.data     = (state == UNCACHED) ? dreq.data : ram_rdata;
    assign creq.len      = (state == UNCACHED) ? MLEN1 : MLEN16;
	assign creq.burst	 = (state == UNCACHED) ? AXI_BURST_FIXED : AXI_BURST_INCR;

    always_comb
    begin
        if(state == WRITEBACK)
        begin
            if(line_saved == 0)
            begin
                creq.addr = {get_tag_line0(ram_rmeta), index, 7'b0};
            end
            else
            begin
                creq.addr = {get_tag_line1(ram_rmeta), index, 7'b0};
            end
        end
        else if(state == FETCH)
        begin
            creq.addr = {dreq.addr[63:7], 4'b0, dreq.addr[2:0]};
        end
        else
            creq.addr = dreq.addr;
    end


    u3 init_count;
    // the FSM
    always_ff @(posedge clk)
    begin
        init_count <= '0;
        random <= '0;
        if (~reset) 
        begin
            random <= random + 1;
            unique case (state)
            INIT: 
            if (dreq.valid) 
            begin
                offset <= '0;
                req <= dreq;
                line_saved <= index_line;
                line_saved_for_writeback <= index_line;
                if(dreq.addr[31] == 0)
                begin
                    state <= UNCACHED;
                end
                else if(hit == 0)
                begin
                    if(dirty_flag == 1)
                        state <= WRITEBACK;
                    else
                        state <= FETCH;
                end
                else
                    state <= INIT;
            end

            FETCH: 
            if (cresp.ready) 
            begin
                state  <= cresp.last ? INIT : FETCH;
                offset <= offset + 1;
            end

            WRITEBACK: 
            if (cresp.ready) 
            begin
                state  <= cresp.last ? FETCH : WRITEBACK;
                offset <= offset + 1;
            end

            UNCACHED:
            if (cresp.ready) 
            begin
                state  <= cresp.last ? INIT : UNCACHED;
            end

            default:
            begin
                
            end

            endcase
        end
 
        else 
        begin
            index_reset <= init_count;
            init_count <= init_count + 1;
        end
    end
`else

    typedef enum u2 {
		IDLE,
		FETCH,
		READY,
		FLUSH
	} state_t /* verilator public */;

	// typedefs
    typedef union packed {
        word_t data;
        u8 [7:0] lanes;
    } view_t;

    typedef u4 offset_t;

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
    } ram;
    word_t ram_rdata;

    always_comb
    unique case (state)
    FETCH: begin
        ram.en     = 1;
        ram.strobe = 8'b11111111;
        ram.wdata  = cresp.data;
    end

    READY: begin
        ram.en     = 1;
        ram.strobe = req.strobe;
        ram.wdata  = req.data;
    end

    default: ram = '0;
    endcase

    RAM_SinglePort #(
		.ADDR_WIDTH(4),
		.DATA_WIDTH(64),
		.BYTE_WIDTH(8),
		.READ_LATENCY(0)
	) ram_inst (
        .clk(clk), .en(ram.en),
        .addr(offset),
        .strobe(ram.strobe),
        .wdata(ram.wdata),
        .rdata(ram_rdata)
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
    if (~reset) begin
        unique case (state)
        IDLE: if (dreq.valid) begin
            state  <= FETCH;
            req    <= dreq;
            offset <= start;
        end

        FETCH: if (cresp.ready) begin
            state  <= cresp.last ? READY : FETCH;
            offset <= offset + 1;
        end

        READY: begin
            state  <= (|req.strobe) ? FLUSH : IDLE;
        end

        FLUSH: if (cresp.ready) begin
            state  <= cresp.last ? IDLE : FLUSH;
            offset <= offset + 1;
        end

        endcase
    end else begin
        state <= IDLE;
        {req, offset} <= '0;
    end


`endif

endmodule

`endif
