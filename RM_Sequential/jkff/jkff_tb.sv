`timescale 1ns/1ps

module jkff_tb;

    logic clk, rstn, en, j, k, q;

    jkff dut (
        .clk  (clk),
        .rstn (rstn),
        .en   (en),
        .j    (j),
        .k    (k),
        .q    (q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Check expected output
    task automatic check_q(
        input logic expected,
        input string test_name
    );
        if (q !== expected)
            $fatal(1, "FAIL: %s | expected=%b, got=%b",
                   test_name, expected, q);
        else
            $display("PASS: %s | q=%b", test_name, q);
    endtask


    initial begin

        rstn = 0;
        en   = 0;
        j    = 0;
        k    = 0;

        #2;
        check_q(1'b0, "Asynchronous reset");


        // ----------------------------------------
        // Release reset
        // ----------------------------------------
        rstn = 1;

        // ----------------------------------------
        // Enable = 0 -> HOLD
        // ----------------------------------------
        en = 0;
        j  = 1;
        k  = 0;

        @(posedge clk);
        #1;

        check_q(1'b0, "Enable disabled -> hold");


        // ----------------------------------------
        // J=0, K=0 -> HOLD
        // ----------------------------------------
        en = 1;
        j  = 0;
        k  = 0;

        @(posedge clk);
        #1;

        check_q(1'b0, "J=0 K=0 -> hold");


        // ----------------------------------------
        // J=1, K=0 -> SET
        // ----------------------------------------
        j = 1;
        k = 0;

        @(posedge clk);
        #1;

        check_q(1'b1, "J=1 K=0 -> set");


        // ----------------------------------------
        // J=0, K=0 -> HOLD
        // ----------------------------------------
        j = 0;
        k = 0;

        @(posedge clk);
        #1;

        check_q(1'b1, "J=0 K=0 -> hold");


        // ----------------------------------------
        // J=0, K=1 -> CLEAR
        // ----------------------------------------
        j = 0;
        k = 1;

        @(posedge clk);
        #1;

        check_q(1'b0, "J=0 K=1 -> clear");


        // ----------------------------------------
        // J=1, K=1 -> TOGGLE
        // ----------------------------------------
        j = 1;
        k = 1;

        @(posedge clk);
        #1;

        check_q(1'b1, "J=1 K=1 -> toggle 0->1");


        @(posedge clk);
        #1;

        check_q(1'b0, "J=1 K=1 -> toggle 1->0");


        // ----------------------------------------
        // Test asynchronous reset
        // ----------------------------------------
        j = 1;
        k = 0;

        @(posedge clk);
        #1;

        check_q(1'b1, "Set before asynchronous reset");

        // Reset does NOT wait for clock
        #2 rstn = 0;
        #1;

        check_q(1'b0, "Asynchronous reset during clock cycle");


        // ----------------------------------------
        // Finish
        // ----------------------------------------
        $display("================================");
        $display("ALL TESTS PASSED");
        $display("================================");

        $finish;
    end

endmodule