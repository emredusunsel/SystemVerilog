`timescale 1ps/1ps

module full_adder_tb;

    logic a, b, cin, s, cout;

    full_adder dut(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, full_adder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  cin=%b  s=%b. cout=%b", $time, a, b, cin, s, cout);

        // Apply test vectors
        a = 0; b = 0; cin = 0; #10;
        a = 0; b = 1; cin = 0; #10;
        a = 1; b = 0; cin = 0; #10;
        a = 1; b = 1; cin = 0; #10;
        a = 0; b = 0; cin = 1; #10;
        a = 0; b = 1; cin = 1; #10;
        a = 1; b = 0; cin = 1; #10;
        a = 1; b = 1; cin = 1; #10;

        $finish;
    end

endmodule
