`timescale 1ps/1ps

module pe_ne_det_tb;

    logic clk, signal, pe, ne;

    pe_ne_det dut(
        .clk(clk),
        .signal(signal),
        .pe(pe),
        .ne(ne)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pe_ne_det_tb);

        signal = 0; #10;
        signal = 1; #30;
        signal = 0; #20;
        signal = 1; #55;
        signal = 0; #20;
        signal = 1; #15;
        signal = 0; #40;

        $finish;
    end

endmodule
