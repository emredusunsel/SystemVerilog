`timescale 1ps/1ps

module half_adder_tb;

    logic a, b, s, c;

    half_adder dut(
        .a(a),
        .b(b),
        .s(s),
        .c(c)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, half_adder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  s=%b. c=%b", $time, a, b, s, c);

        // Apply test vectors
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end

endmodule
