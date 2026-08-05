`timescale 1ps/1ps

module barrel_tb;

    localparam WIDTH = 8;
    
    logic   [WIDTH-1:0] data, result;
    logic   [$clog2(WIDTH)-1:0] shamt;

    barrel dut(
        .data(data),
        .shamt(shamt),
        .result(result)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, barrel_tb);

        $display(" Time      data       shamt  result");
        $monitor("%4t   %b   %0d    %b", $time, data, shamt, result);

        // Test every one-hot input
        for (int i = 0; i < WIDTH; i++) begin
            data = 8'b10111010;
            shamt = i;
            #10;
        end

        #10;

        $finish;
    end

endmodule
