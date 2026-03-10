// fifo_ctrl.sv

`default_nettype none

module fifo_ctrl # (
    parameter int ADDR_WIDTH = 4
)(
    input   var logic                       clk,
    input   var logic                       rst_n,

    // read interface
    input   var logic                       i_re,
    output  var logic   [ADDR_WIDTH-1:0]    o_raddr,
    output  var logic                       o_rempty,

    // write interface
    input   var logic                       i_we,
    output  var logic   [ADDR_WIDTH-1:0]    o_waddr,
    output  var logic                       o_wfull
);

// read pointer
logic [ADDR_WIDTH-1:0]  rptr;
logic [ADDR_WIDTH-1:0]  rptr_succ;
logic [ADDR_WIDTH-1:0]  next_rptr;

// write pointer
logic [ADDR_WIDTH-1:0]  wptr;
logic [ADDR_WIDTH-1:0]  wptr_succ;
logic [ADDR_WIDTH-1:0]  next_wptr;

// full and empty flags
logic full;
logic next_full;
logic empty;
logic next_empty;


// registers
always_ff @(posedge clk) begin
    if (!rst_n) begin
        rptr <= 0;
        empty <= 1'b1;
        wptr <= 0;
        full <= 1'b0;
    end else begin
        rptr <= next_rptr;
        empty <= next_empty;
        wptr <= next_wptr;
        full <= next_full;
    end
end

always_comb begin
    // initialize values prior to logic
    rptr_succ = rptr + 1;
    next_rptr = rptr;
    next_empty = empty;
    wptr_succ = wptr + 1;
    next_wptr = wptr;
    next_full = full;

    // logic
    unique case ({i_we, i_re})
        2'b01: begin    // read
            if (!empty) begin
                next_rptr = rptr_succ;
                next_full = 1'b0;
                if (rptr_succ == wptr) begin
                    next_empty = 1'b1;
                end
            end
        end

        2'b10: begin    // write
            if (i_we && !full) begin
                next_wptr = wptr_succ;
                next_empty = 1'b0;
                if (next_wptr == rptr) begin
                    next_full = 1'b1;
                end
            end
        end

        2'b11: begin    // read and write
            next_wptr = wptr;
            next_rptr = rptr;
        end

        default: ;   // no op
    endcase
end

assign o_raddr = rptr;
assign o_rempty = empty;

assign o_waddr = wptr;
assign o_wfull = full;

endmodule
