`timescale 1ns/1ps

module sync_2ff_tb;

logic clk, rstn, async_in, sync_out;

sync_2ff dut (
    .clk      (clk),
    .rstn     (rstn),
    .async_in (async_in),
    .sync_out (sync_out)
);

// 10 ns clock period
always #5 clk = ~clk;

initial begin
    clk      = 0;
    rstn     = 0;
    async_in = 0;

    // -------------------------
    // Reset
    // -------------------------
    #12;
    rstn = 1;

    // -------------------------
    // 0 -> 1
    // -------------------------
    #7;
    async_in = 1;

    // -------------------------
    // 1 -> 0
    // -------------------------
    #18;
    async_in = 0;

    // -------------------------
    // 0 -> 1
    // -------------------------
    #13;
    async_in = 1;

    // -------------------------
    // Reset while input is high
    // -------------------------
    #7;
    rstn = 0;

    #8;
    rstn = 1;

    // -------------------------
    // 1 -> 0
    // -------------------------
    #17;
    async_in = 0;

    #20;
    $finish;
end

initial begin
    $monitor(
        "time=%0t | rstn=%b | async_in=%b | sync1=%b | sync_out=%b",
        $time, rstn, async_in, dut.sync1, sync_out
    );
end

endmodule
