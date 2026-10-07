`timescale 1ns/1ps

module fsm_tb;

    localparam time CLK_PERIOD = 10ns;

    logic clk, rstn, start, done, error;
    logic busy, valid, fault;

    fsm dut (
        .clk   (clk),
        .rstn  (rstn),
        .start (start),
        .done  (done),
        .error (error),
        .busy  (busy),
        .valid (valid),
        .fault (fault)
    );

    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        rstn  = 1'b0;
        start = 1'b0;
        done  = 1'b0;
        error = 1'b0;

        #2;

        if (busy || valid || fault)
            $fatal(1, "FAIL: Outputs incorrect during reset");

        // Release reset away from active clock edge
        @(negedge clk);
        rstn = 1'b1;

        // ------------------------------------------------------------
        // IDLE
        // ------------------------------------------------------------
        @(posedge clk);
        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: Incorrect IDLE outputs");

        // ------------------------------------------------------------
        // IDLE -> BUSY
        // ------------------------------------------------------------
        @(negedge clk);
        start = 1'b1;

        @(posedge clk);
        #1;

        if (!busy || valid || fault)
            $fatal(1, "FAIL: IDLE -> BUSY");

        @(negedge clk);
        start = 1'b0;

        // ------------------------------------------------------------
        // BUSY -> BUSY
        // No done/error, should remain BUSY
        // ------------------------------------------------------------
        @(posedge clk);
        #1;

        if (!busy || valid || fault)
            $fatal(1, "FAIL: BUSY -> BUSY");

        // ------------------------------------------------------------
        // BUSY -> DONE
        // ------------------------------------------------------------
        @(negedge clk);
        done = 1'b1;

        @(posedge clk);
        #1;

        if (busy || !valid || fault)
            $fatal(1, "FAIL: BUSY -> DONE");

        @(negedge clk);
        done = 1'b0;

        // ------------------------------------------------------------
        // DONE -> IDLE
        // ------------------------------------------------------------
        @(posedge clk);
        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: DONE -> IDLE");

        // ------------------------------------------------------------
        // IDLE -> BUSY
        // Prepare for ERROR test
        // ------------------------------------------------------------
        @(negedge clk);
        start = 1'b1;

        @(posedge clk);
        #1;

        if (!busy || valid || fault)
            $fatal(1, "FAIL: IDLE -> BUSY before ERROR");

        @(negedge clk);
        start = 1'b0;

        // ------------------------------------------------------------
        // BUSY -> ERROR
        // ------------------------------------------------------------
        @(negedge clk);
        error = 1'b1;

        @(posedge clk);
        #1;

        if (busy || valid || !fault)
            $fatal(1, "FAIL: BUSY -> ERROR");

        @(negedge clk);
        error = 1'b0;

        // ------------------------------------------------------------
        // ERROR -> IDLE
        // ------------------------------------------------------------
        @(posedge clk);
        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: ERROR -> IDLE");

        // ------------------------------------------------------------
        // IDLE -> BUSY
        // Prepare for priority test
        // ------------------------------------------------------------
        @(negedge clk);
        start = 1'b1;

        @(posedge clk);
        #1;

        if (!busy || valid || fault)
            $fatal(1, "FAIL: IDLE -> BUSY before priority test");

        @(negedge clk);
        start = 1'b0;

        // ------------------------------------------------------------
        // ERROR priority over DONE
        // Both asserted simultaneously.
        // ERROR should win.
        // ------------------------------------------------------------
        @(negedge clk);
        done  = 1'b1;
        error = 1'b1;

        @(posedge clk);
        #1;

        if (busy || valid || !fault)
            $fatal(1, "FAIL: ERROR priority over DONE");

        @(negedge clk);
        done  = 1'b0;
        error = 1'b0;

        // ------------------------------------------------------------
        // ERROR -> IDLE
        // ------------------------------------------------------------
        @(posedge clk);
        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: ERROR -> IDLE after priority test");

        // ------------------------------------------------------------
        // Reset while BUSY
        // ------------------------------------------------------------
        @(negedge clk);
        start = 1'b1;

        @(posedge clk);
        #1;

        if (!busy)
            $fatal(1, "FAIL: Could not enter BUSY before reset test");

        @(negedge clk);
        start = 1'b0;

        // Assert asynchronous reset between clock edges
        #2;
        rstn = 1'b0;

        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: Asynchronous reset while BUSY");

        // ------------------------------------------------------------
        // Release reset
        // ------------------------------------------------------------
        @(negedge clk);
        rstn = 1'b1;

        @(posedge clk);
        #1;

        if (busy || valid || fault)
            $fatal(1, "FAIL: Incorrect state after reset release");

        // ------------------------------------------------------------
        // Test complete
        // ------------------------------------------------------------
        $display("========================================");
        $display("           ALL TESTS PASSED            ");
        $display("========================================");

        $finish;
    end

endmodule
