`timescale 1ns/1ps

module and_gate_tb;

    logic a;
    logic b;
    logic y;

    // Instantiate the DUT (Design Under Test)
    and_gate dut (
        .a(a),
        .b(b),
        .y(y)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, and_gate_tb);

        // Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  y=%b", $time, a, b, y);

        // Apply test vectors
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;

        $finish;
    end

endmodule