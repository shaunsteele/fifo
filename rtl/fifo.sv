// fifo.sv

`default_nettype none

module fifo # (
  parameter int ALEN = 8,
  parameter int DLEN = 8,
  parameter int INCR = 1
)(
  input var                     clk,
  input var                     rstn,

  // AXI Stream Write Port
  input var                     i_wr_tvalid,
  output var                    o_wr_tready,
  input var         [DLEN-1:0]  i_wr_tdata,

  // AXI Stream Read Port
  output var logic              o_rd_tvalid,
  input var                     i_rd_tready,
  output var logic  [DLEN-1:0]  o_rd_tdata
);

/* Pointer Instantiations */
logic [ALEN-1:0]  waddr;
logic [ALEN:0]    wptr;
logic [ALEN-1:0]  raddr;
logic [ALEN:0]    rptr;

// Write Pointer
logic ram_wen;
wr_ptr # (
  .ALEN (ALEN),
  .INCR (INCR)
) u_WR (
  .clk          (clk),
  .rstn         (rstn),
  .i_tvalid     (i_wr_tvalid),
  .o_tready     (o_wr_tready),
  .o_waddr      (waddr),
  .o_wptr       (wptr),
  .i_rptr       (rptr),
  .o_ram_wen    (ram_wen)
);

// Read Pointer
logic ram_ren;
rd_ptr # (
  .ALEN (ALEN),
  .INCR (INCR)
) u_RD (
  .clk          (clk),
  .rstn         (rstn),
  .o_tvalid     (o_rd_tvalid),
  .i_tready     (i_rd_tready),
  .o_raddr      (raddr),
  .o_rptr       (rptr),
  .i_wptr       (wptr),
  .o_ram_ren    (ram_ren)
);

/* Memory Instantiation */
sp_ram # (
  .DLEN (DLEN),
  .ALEN (ALEN)
) u_RAM (
  .clk      (clk),
  .rstn     (rstn),
  .i_wen    (ram_wen),
  .i_waddr  (waddr),
  .i_wdata  (i_wr_tdata),
  .i_ren    (ram_ren),
  .i_raddr  (raddr),
  .o_rdata  (o_rd_tdata)
);


endmodule
