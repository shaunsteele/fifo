// wr_ptr.sv

`default_nettype none

module wr_ptr # (
  parameter int ALEN = 8,
  parameter int INCR = 1
)(
  input var                     clk,
  input var                     rstn,

  input var                     i_tvalid,
  output var logic              o_tready,

  output var logic  [ALEN-1:0]  o_waddr,
  output var logic  [ALEN:0]    o_wptr,
  input var         [ALEN:0]    i_rptr,

  output var logic              o_ram_wen
);


// Write Pointer Increment Logic
logic [ALEN:0]  next_wptr;
always_comb begin
  next_wptr = o_wptr + INCR[ALEN:0];
end

// Valid RAM Write Flag
always_comb begin
  o_ram_wen = i_tvalid & o_tready;
end

// Next Pointer Logic
logic [ALEN:0]  wptr_d;
always_comb begin
  if (o_ram_wen) begin
    wptr_d = next_wptr;
  end else begin
    wptr_d = o_wptr;
  end
end

// Write Pointer Register
always_ff @(posedge clk) begin
  if (!rstn) begin
    o_wptr <= 0;
  end else begin
    o_wptr <= wptr_d;
  end
end

assign o_waddr = o_wptr[ALEN-1:0];

// Full Latch
logic rstn_q;
always_ff @(posedge clk) begin
  rstn_q <= rstn;
end

logic full;
always_comb begin
  full = {~wptr_d[ALEN], wptr_d[ALEN-1:0]} == i_rptr;
end

always_ff @(posedge clk) begin
  if (!rstn) begin
    o_tready <= 0;
  end else begin
    if (rstn && !rstn_q) begin
      o_tready <= 1;
    end else begin
      o_tready <= ~full;
    end
  end
end

endmodule
