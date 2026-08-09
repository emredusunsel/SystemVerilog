`timescale 1ps/1ps

module tff_tb;

    logic clk, rstn, t, q;

    tff dut(
        .clk(clk),
        .rstn(rstn),
        .t(t),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display(" Time   t  q");
        $monitor("%4t   %b   %b", $time, t, q);

        rstn = 0; t = 0; #10;

        rstn = 1; #20;
        t = 1; #40;
        t = 0; #40;

        t = 1; #30;
        t = 0; #30;
        $finish;
    end

endmodule
