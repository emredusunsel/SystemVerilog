`timescale 1ps/1ps

module comparator_tb;

    logic [7:0] a, b;
    logic eq, gt, lt;

    comparator dut(
        .a(a),
        .b(b),
        .eq(eq),
        .gt(gt),
        .lt(lt)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, comparator_tb);

        $display(" Time      a          b   eq  gt  lt");
        $monitor("%4t   %d   %d    %b   %b  %b", $time, a, b, eq, gt, lt);

        a = 0; b = 0; #10;
        a = 5; b = 5; #10;
        a = 10; b = 3; #10;
        a = 3; b = 10; #10;
        a = 8'hFF; b = 8'hFF; #10;
        a = 8'hFF; b = 0; #10;
        a = 0; b = 8'hFF; #10;

        $finish;
    end

endmodule
