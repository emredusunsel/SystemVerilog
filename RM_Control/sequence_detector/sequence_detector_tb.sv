`timescale 1ps/1ps

module sequence_detector_tb;

    logic clk, rstn, in, out;

    sequence_detector dut(
        .clk(clk),
        .rstn(rstn),
        .in(in),
        .out(out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, sequence_detector_tb);

        $monitor("%t State = %d In = %b Out = %b",$time, dut.state, in, out);
        rstn = 1;
        in = 1;
        #10;
        in = 0;
        #10;
        in = 1;
        #30;
        in = 1;
        #30;
        in = 0;
        #10;
        in = 1;
        #40;
        in = 0;
        #30;
        in = 1;
        #10;
        in = 0;
        #10;
        in = 1;
        #10;
        in = 0;
        #20;
        $finish;
    end

endmodule
