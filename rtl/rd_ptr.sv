// rd_ptr.sv

`default_nettype none

module rd_ptr # (
  parameter int ALEN = 8,
  parameter int INCR = 1
)(
  input var                     clk,
  input var                     rstn,

  output var logic              o_tvalid,
  input var                     i_tready,

  output var logic  [ALEN-1:0]  o_raddr,
  output var logic  [ALEN:0]    o_rptr,
  input var         [ALEN:0]    i_wptr
);

// Read Pointer Increment Logic
logic [ALEN:0]  next_rptr;
always_comb begin
  next_rptr = o_rptr + INCR[ALEN:0];
end

// Valid RAM Read Flag
logic ren;
always_comb begin
  ren = o_tvalid & i_tready;
end

// Next Read Pointer Logic
logic [ALEN:0]  rptr_d;
always_comb begin
  if (ren) begin
    rptr_d = next_rptr;
  end else begin
    rptr_d = o_rptr;
  end
end

// Read Pointer Register
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_rptr <= 0;
  end else begin
    o_rptr <= rptr_d;
  end
end

assign o_raddr = rptr_d[ALEN-1:0];

// Empty Logic
logic empty;
always_comb begin
  empty = rptr_d == i_wptr;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_tvalid <= 0;
  end else begin
    o_tvalid <= ~empty;
  end
end


endmodule
