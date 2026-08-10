`timescale 1ps/1ps

module encoder_tb;

    logic [7:0] d;
    logic [2:0] y;
    logic valid;

    encoder dut(
        .d(d),
        .y(y),
        .valid(valid)
    );

    integer i;

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, encoder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  d=%02h  y=%d  valid=%b", $time, d, y, valid);

        // Apply test vectors
        for (i = 0; i < 8; i++) begin
            d = 8'b1 << i;
            #10;
        end
        
        d = 8'b01010101; #10;
        d = 8'b00010011; #10;
        d = '0; #10;

        $finish;
    end

endmodule
