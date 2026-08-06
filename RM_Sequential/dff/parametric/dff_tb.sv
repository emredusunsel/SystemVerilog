`timescale 1ns/1ps

module dff_tb;

    localparam int WIDTH = 4;

    localparam logic [WIDTH-1:0] DATA0 = 'hA;
    localparam logic [WIDTH-1:0] DATA1 = 'hC;
    localparam logic [WIDTH-1:0] DATA2 = 'h3;
    localparam logic [WIDTH-1:0] DATA3 = '1;

    logic               clk, rstn, en;
    logic [WIDTH-1:0]   d, q;

    // DUT
    dff #(.WIDTH(WIDTH)) dut(
        .clk  (clk),
        .rstn (rstn),
        .en   (en),
        .d    (d),
        .q    (q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_q(input logic [WIDTH-1:0] expected);
        #1;    // Wait for non-blocking assignment update

        assert (q == expected)
            else $fatal(1, "FAIL @ %0t ns: Expected q = %h, Got q = %h",
                        $time, expected, q);

        $display("PASS @ %0t ns: q = %h",
                $time, q);
    endtask

    initial begin
        $display("===== DFF TEST START =====");

        rstn = 0;
        en   = 0;
        d    = '0;

        // ----------------------------
        // Test 1 : Asynchronous Reset
        // ----------------------------
        #1;
        check_q('0);

        // Release reset
        #9;
        rstn = 1;

        // ----------------------------
        // Test 2 : Load DATA0
        // ----------------------------
        en = 1;
        d  = DATA0;

        @(posedge clk);
        check_q(DATA0);

        // ----------------------------
        // Test 3 : Load DATA1
        // ----------------------------
        d = DATA1;

        @(posedge clk);
        check_q(DATA1);

        // ----------------------------
        // Test 4 : Hold value
        // ----------------------------
        en = 0;
        d  = DATA2;

        @(posedge clk);
        check_q(DATA1);

        // ----------------------------
        // Test 5 : Enable again
        // ----------------------------
        en = 1;

        @(posedge clk);
        check_q(DATA2);

        // ----------------------------
        // Test 6 : Async reset during operation
        // ----------------------------
        #2;
        rstn = 0;

        check_q('0);

        // ----------------------------
        // Test 7 : Operate after reset
        // ----------------------------
        rstn = 1;
        d    = DATA3;

        @(posedge clk);
        check_q(DATA3);

        $display("\n===== ALL TESTS PASSED =====");
        $finish;
    end

endmodule
