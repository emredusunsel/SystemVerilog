`timescale 1ps/1ps

module barrel_tb;

    logic [3:0] data, result;
    logic [1:0] shamt;

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
        data = 4'b0001; shamt = 0; #10;
        data = 4'b0001; shamt = 1; #10;
        data = 4'b0001; shamt = 2; #10;
        data = 4'b0001; shamt = 3; #10;
        
        data = 4'b1001; shamt = 0; #10;
        data = 4'b1001; shamt = 1; #10;
        data = 4'b1001; shamt = 2; #10;
        data = 4'b1001; shamt = 3; #10;
        
        data = 4'b0101; shamt = 0; #10;
        data = 4'b0101; shamt = 1; #10;
        data = 4'b0101; shamt = 2; #10;
        data = 4'b0101; shamt = 3; #10;
        
        $finish;
    end

endmodule
