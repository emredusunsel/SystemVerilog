`timescale 1ps/1ps

module barrel_tb;

    logic [7:0] data, result;
    logic [2:0] shamt;

    barrel dut(
        .data(data),
        .shamt(shamt),
        .result(result)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, barrel_tb);

        // Print values whenever they change
        $monitor("Time=%0t  data=%b  shamt=%d  result=%b", $time, data, shamt, result);

        // Apply test vectors
        data = 8'b0001_1100; shamt = 0; #10;
        data = 8'b0001_1100; shamt = 1; #10;
        data = 8'b0001_1100; shamt = 2; #10;
        data = 8'b0001_1100; shamt = 3; #10;
        
        data = 8'b1001_1100; shamt = 4; #10;
        data = 8'b1001_1100; shamt = 5; #10;
        data = 8'b1001_1100; shamt = 6; #10;
        data = 8'b1001_1100; shamt = 7; #10;
        
        data = 8'b0101_1100; shamt = 0; #10;
        data = 8'b0101_1100; shamt = 1; #10;
        data = 8'b0101_1100; shamt = 2; #10;
        data = 8'b0101_1100; shamt = 3; #10;
        
        $finish;
    end

endmodule
