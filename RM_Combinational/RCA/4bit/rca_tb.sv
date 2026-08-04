`timescale 1ps/1ps

module rca_tb;

    logic [3:0] a, b, s;
    logic cin, cout;

    rca dut(
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, rca_tb);

        // Print values whenever they change
        $monitor("Time=%0t  a=%d  b=%d  cin=%b  s=%d  cout=%b", $time, a, b, cin, s, cout);

        // Apply test vectors
        a = 4'd0; b = 4'd0; cin = 0; #10;
        a = 4'd2; b = 4'd2; cin = 0; #10;
        a = 4'd4; b = 4'd6; cin = 0; #10;
        a = 4'd10; b = 4'd8; cin = 0; #10;

        a = 4'd15; b = 4'd15; cin = 0; #10;
        a = 4'd15; b = 4'd1; cin = 0; #10;
        a = 4'd0; b = 4'd15; cin = 1; #10;
        a = 4'd15; b = 4'd15; cin = 1; #10;

        $finish;
    end

endmodule
