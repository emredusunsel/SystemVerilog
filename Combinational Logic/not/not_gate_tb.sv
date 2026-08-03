`timescale 1ps/1ps

module not_gate_tb;

    logic a, y;

    not_gate dut(
        .a(a),
        .y(y)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, not_gate_tb);

        // Print values whenever they change
        $monitor("Time=%0t  a=%b  y=%b", $time, a, y);

        // Apply test vectors
        a = 0; #10;
        a = 1; #10;

        $finish;
    end

endmodule
