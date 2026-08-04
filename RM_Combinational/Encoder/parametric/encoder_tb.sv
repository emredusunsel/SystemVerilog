`timescale 1ns/1ps

module encoder_tb;

    localparam WIDTH   = 8;
    localparam Y_WIDTH = $clog2(WIDTH);

    logic [  WIDTH-1:0] d;
    logic [Y_WIDTH-1:0] y;
    logic valid;

    encoder #(
        .WIDTH(WIDTH)
    ) dut (
        .d(d),
        .y(y),
        .valid(valid)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, encoder_tb);

        $display(" Time      d          y  valid");
        $monitor("%4t   %b   %0d    %b", $time, d, y, valid);

        // Test every one-hot input
        for (int i = 0; i < WIDTH; i++) begin
            d = '0;
            d[i] = 1'b1;
            #10;
        end

        // Invalid inputs
        d = '0;
        #10;

        d = '1;
        #10;

        d = 8'b00101000;
        #10;

        $finish;
    end

endmodule
