`timescale 1ns/1ps

module ripple_counter_tb;

    localparam int WIDTH = 4;

    logic               clk;
    logic               rstn;
    logic [WIDTH-1:0]   q;

    ripple_counter #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .q(q)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;


    task automatic check(
        input logic [WIDTH-1:0] expected,
        input string            msg
    );
        #1;

        if (q !== expected) begin
            $error(
                "FAIL: %s | expected=%b, got=%b | time=%0t",
                msg, expected, q, $time
            );
        end
        else begin
            $display(
                "PASS: %s | q=%b | time=%0t",
                msg, q, $time
            );
        end
    endtask


    initial begin
        $display("================================");
        $display("      RIPPLE COUNTER TB");
        $display("================================");

        // -------------------------
        // Reset
        // -------------------------
        rstn = 0;

        #2;
        check(4'b0000, "reset asserted");

        // Release reset
        rstn = 1;

        // -------------------------
        // Count
        // -------------------------

        @(posedge clk);
        check(4'b0001, "count 1");

        @(posedge clk);
        check(4'b0010, "count 2");

        @(posedge clk);
        check(4'b0011, "count 3");

        @(posedge clk);
        check(4'b0100, "count 4");

        @(posedge clk);
        check(4'b0101, "count 5");

        @(posedge clk);
        check(4'b0110, "count 6");

        @(posedge clk);
        check(4'b0111, "count 7");

        @(posedge clk);
        check(4'b1000, "count 8");

        @(posedge clk);
        check(4'b1001, "count 9");

        @(posedge clk);
        check(4'b1010, "count 10");

        @(posedge clk);
        check(4'b1011, "count 11");

        @(posedge clk);
        check(4'b1100, "count 12");

        @(posedge clk);
        check(4'b1101, "count 13");

        @(posedge clk);
        check(4'b1110, "count 14");

        @(posedge clk);
        check(4'b1111, "count 15");

        @(posedge clk);
        check(4'b0000, "rollover");

        // -------------------------
        // Test reset again
        // -------------------------

        #2;
        rstn = 0;

        check(4'b0000, "asynchronous reset");

        #3;
        rstn = 1;

        @(posedge clk);
        check(4'b0001, "count after reset");

        $display("================================");
        $display("          TEST COMPLETE");
        $display("================================");

        $finish;
    end

endmodule