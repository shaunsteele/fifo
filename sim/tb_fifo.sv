// tb_fifo.sv

`default_nettype none

module tb_fifo;

// clock
bit clk;
initial begin
    clk = 0;
    forever #10 clk = ~clk;
end

// reset
bit rst_n;
initial begin
    rst_n = 0;
    repeat (10) @(negedge clk);
    rst_n = 1;
end


// DUT signals
parameter int DATA_WIDTH = 8;
parameter int ADDR_WIDTH = 2;

bit                     re;
bit [DATA_WIDTH-1:0]    rdata;
bit                     rempty;

bit                     we;
bit [DATA_WIDTH-1:0]    wdata;
bit                     wfull;

// DUT Instantiation
fifo # (
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) u_DUT (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_re       (re),
    .o_rdata    (rdata),
    .o_rempty   (rempty),
    .i_we       (we),
    .i_wdata    (wdata),
    .o_wfull    (wfull)
);


// model
bit [DATA_WIDTH-1:0]    model_fifo[2 ** ADDR_WIDTH];
bit [ADDR_WIDTH-1:0]    model_rptr = 0;
bit [ADDR_WIDTH-1:0]    model_wptr = 0;
bit                     model_full;
bit                     model_empty;

always_comb begin
    model_full = model_rptr == (model_wptr - 1);
    model_empty = model_rptr == model_wptr;
end

// test functions/tasks
function automatic void reset_inputs();
    we = 0;
    wdata = 0;
    re = 0;
    log("Inputs Reset");
endfunction

task automatic write(input bit [DATA_WIDTH-1:0] data);
    log($sformatf("FIFO Write:\t0x%08h", data));
    @(negedge clk);
    wdata = data;
    model_fifo[model_wptr] = data;

    we = 1;

    @(negedge clk);
    we = 0;
    model_wptr = model_wptr + 1;
endtask

task automatic read(output bit [DATA_WIDTH-1:0] data);
    @(negedge clk);
    re = 1;

    @(negedge clk);
    assert(rdata == model_fifo[model_rptr])
    else $error("\n\trdata:\t\t0x%08h\n\tmodel_fifo[%d]:\t0x%08h",
        rdata,model_rptr,model_fifo[model_rptr]);
    data = rdata;
    re = 0;

    @(posedge clk);
    model_rptr = model_rptr + 1;
    log($sformatf("FIFO Read:\t0x%08h", data));
endtask

task automatic write_read_test();
    bit [DATA_WIDTH-1:0] test_in;
    bit [DATA_WIDTH-1:0] test_out;

    log("Write then Read Test - Starting");

    test_in = DATA_WIDTH'($urandom());
    write(test_in);
    repeat (5) @(posedge clk);
    read(test_out);

    log("Write then Read Test - Passed");
endtask

task automatic full_test();
    bit [DATA_WIDTH-1:0]    test_data[2 ** ADDR_WIDTH];

    log("Full Test - Starting");

    // fill write data buffer with random values
    foreach(test_data[i]) begin
        test_data[i] = DATA_WIDTH'($urandom());
    end

    // write buffer to FIFO
    foreach(test_data[i]) begin
        write(test_data[i]);
    end
    assert(wfull)
    else $error("FIFO full flag not set");

    log("Full Test - Passed");
endtask

task automatic empty_test();
    bit [DATA_WIDTH-1:0]    temp;

    log("Empty Test - Starting");

    for(int i = 0; i < (2 ** ADDR_WIDTH); i++) begin
        read(temp);
    end
    assert(rempty)
    else $error("FIFO empty flag not set");

    log("Empty Test - Passed");
endtask


initial begin
    log("Starting FIFO Test Bench");

    reset_inputs();

    wait(rst_n);
    log("rst_n asserted");

    // test cases
    write_read_test();
    full_test();
    empty_test();

    log("Test finished");
    $finish();
end

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0);
end

function automatic void log(string s);
    $display("[%0t]:\t%s", $realtime, s);
endfunction

endmodule
