`timescale 1ps/1ps

// Pattern: 110101

module pattern_detector_tb;

    logic clk, rstn, in, out;

    pattern_detector dut(
        .clk(clk),
        .rstn(rstn),
        .in(in),
        .out(out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pattern_detector_tb);

        $monitor("%t %b %b %b", $time, in, dut.state, out);

        rstn = 1;
        in = 0;
        #10;

        in = 1; #20;
        in = 0; #10;
        in = 1; #10;
        in = 0; #10;
        in = 1; #10;
        in = 0; #10;
        in = 1; #10;

        #20;
        $finish;

    end

endmodule
