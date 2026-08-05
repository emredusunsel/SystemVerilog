
module dff_tb;

    logic clk, rstn;
    logic [3:0] d, q;

    dff dut(
        .clk(clk),
        .rstn(rstn),
        .d(d),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dff_tb);

        $display(" Time      d       q");
        $monitor("%4t   %b   %b   ", $time, d, q);

        rstn = 1;
        d = 4'b1100; #10;
        #10;
        d = 4'b0101; #10;

        #10;

        $finish;
    end

endmodule
