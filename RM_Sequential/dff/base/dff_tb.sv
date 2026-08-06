`timescale 1ns/1ps

module dff_tb;

    logic       clk;
    logic       rstn;
    logic       en;
    logic [3:0] d;
    logic [3:0] q;

    // DUT
    dff dut (
        .clk  (clk),
        .rstn (rstn),
        .en   (en),
        .d    (d),
        .q    (q)
    );

    // 100 MHz clock (10 ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("Time\tclk rstn en d    q");
        $monitor("%0t\t%b    %b    %b  %b  %b",
                 $time, clk, rstn, en, d, q);

        // ----------------------------
        // Initial values
        // ----------------------------
        rstn = 0;
        en   = 0;
        d    = 4'b0000;

        // Hold reset
        #12;

        // Release reset
        rstn = 1;

        // ----------------------------
        // Test 1: Capture data
        // ----------------------------
        en = 1;
        d  = 4'b1010;
        @(posedge clk);

        // ----------------------------
        // Test 2: Capture another value
        // ----------------------------
        d = 4'b1100;
        @(posedge clk);

        // ----------------------------
        // Test 3: Disable enable
        // q should remain unchanged
        // ----------------------------
        en = 0;
        d  = 4'b0011;
        @(posedge clk);

        // ----------------------------
        // Test 4: Enable again
        // ----------------------------
        en = 1;
        @(posedge clk);

        // ----------------------------
        // Test 5: Asynchronous reset
        // ----------------------------
        #2;
        rstn = 0;

        #8;
        rstn = 1;

        // ----------------------------
        // Test 6: Verify operation after reset
        // ----------------------------
        d = 4'b1111;
        en = 1;
        @(posedge clk);

        #10;

        $display("\nSimulation Finished.");
        $finish;
    end

endmodule