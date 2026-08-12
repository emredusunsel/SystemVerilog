`timescale 1ns/1ps

module dff_tb;

    logic clk, rstn, en, d, q;

    dff dut(
        .clk    (clk),
        .rstn   (rstn),
        .en     (en),
        .d      (d),
        .q      (q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_q(input logic expected);
        #1;    // Wait for non-blocking assignment update

        assert (q == expected)
            else $fatal(1, "FAIL @ %0t ns: Expected q = %b, Got q = %b",
                        $time, expected, q);

        $display("PASS @ %0t ns: q = %b",
                $time, q);
    endtask

    initial begin
        $display("===== DFF TEST START =====");

        rstn  = 0;
        en    = 0;
        d     = 0;

        // ----------------------------
        // Test 1 : Asynchronous Reset
        // ----------------------------
        #1;
        check_q('0);

        // Release reset
        #9;
        rstn = 1;

        // ----------------------------
        // Test 2 : Load 1
        // ----------------------------
        en = 1;
        d  = 1;

        @(posedge clk);
        check_q(1);

        // ----------------------------
        // Test 3 : Load 0
        // ----------------------------
        d = 0;

        @(posedge clk);
        check_q(0);

        // ----------------------------
        // Test 4 : Hold value
        // ----------------------------
        en = 0;
        d  = 1;

        @(posedge clk);
        check_q(0);

        // ----------------------------
        // Test 5 : Enable again
        // ----------------------------
        en = 1;

        @(posedge clk);
        check_q(1);

        // ----------------------------
        // Test 6 : Async reset during operation
        // ----------------------------
        #2;
        rstn = 0;

        check_q(0);

        // ----------------------------
        // Test 7 : Operate after reset
        // ----------------------------
        rstn = 1;
        d    = 1;

        @(posedge clk);
        check_q(1);

        $display("\n===== ALL TESTS PASSED =====");
        $finish;
    end

endmodule
