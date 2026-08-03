`timescale 1ps/1ps

module encoder_tb;

    logic [7:0] D;
    logic [2:0] Y;
    logic valid;

    encoder dut(
        .D(D),
        .Y(Y),
        .valid(valid)
    );

    integer i;

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, encoder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  D=%02h  Y=%d  valid=%b", $time, D, Y, valid);

        // Apply test vectors
        for (i = 0; i < 8; i++) begin
            D = 8'b1 << i;
            #10;
        end
        
        D = 8'b01010101; #10;
        D = '0; #10;

        $finish;
    end

endmodule
