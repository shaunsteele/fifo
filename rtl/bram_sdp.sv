// bram_sdp.sv
// simple dual port block ram

`default_nettype none

module bram_sdp # (
  parameter int DATA_WIDTH = 8,
  parameter int ADDR_WIDTH = 4
)(
    input   var logic                       clk,
    input   var logic                       rst_n,

    // write interface
    input   var logic                       i_we,
    input   var logic   [ADDR_WIDTH-1:0]    i_waddr,
    input   var logic   [DATA_WIDTH-1:0]    i_wdata,

    // read interface
    input   var logic   [ADDR_WIDTH-1:0]    i_raddr,
    output  var logic   [DATA_WIDTH-1:0]    o_rdata
);

logic [DATA_WIDTH-1:0]  ram[2 ** ADDR_WIDTH];

logic [DATA_WIDTH-1:0]  rdata;

always_ff @(posedge clk) begin
    if (i_we) begin
        ram[i_waddr] <= i_wdata;
    end
end

always_ff @(posedge clk) begin
    if (!rst_n) begin
        rdata <= 0;
    end else begin
        rdata <= ram[i_raddr];
    end
end

assign o_rdata = rdata;

endmodule
