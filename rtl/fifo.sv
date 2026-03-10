// fifo.sv

`default_nettype none

module fifo # (
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4
)(
    input   var logic                       clk,
    input   var logic                       rst_n,

    // read interface
    input   var logic                       i_re,
    output  var logic   [DATA_WIDTH-1:0]    o_rdata,
    output  var logic                       o_rempty,

    // write interface
    input   var logic                       i_we,
    input   var logic   [DATA_WIDTH-1:0]    i_wdata,
    output  var logic                       o_wfull
);


logic [ADDR_WIDTH-1:0]  waddr;
logic [ADDR_WIDTH-1:0]  raddr;


// write enable without overwrite
logic we;
logic full;

always_comb begin
    we = i_we & ~full;
end

assign o_wfull = full;


// module instantiations
fifo_ctrl # (
    .ADDR_WIDTH (ADDR_WIDTH)
) u_FC (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_re       (i_re),
    .o_raddr    (raddr),
    .o_rempty   (o_rempty),
    .i_we       (we),
    .o_waddr    (waddr),
    .o_wfull    (full)
);

bram_sdp # (
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_BRAM (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_we       (we),
    .i_waddr    (waddr),
    .i_wdata    (i_wdata),
    .i_raddr    (raddr),
    .o_rdata    (o_rdata)
);

endmodule
