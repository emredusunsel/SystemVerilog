`timescale 1ps/1ps

module adder_tb;

    logic [3:0] A, B, S;
    logic cin, cout;

    adder dut(
        .A(A),
        .B(B),
        .cin(cin),
        .S(S),
        .cout(cout)
    );

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, adder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  A=%d  B=%d  cin=%b  S=%d  cout=%b", $time, A, B, cin, S, cout);

        // Apply test vectors
        A = 4'd0; B = 4'd0; cin = 0; #10;
        A = 4'd2; B = 4'd2; cin = 0; #10;
        A = 4'd4; B = 4'd6; cin = 0; #10;
        A = 4'd10; B = 4'd8; cin = 0; #10;

        A = 4'd15; B = 4'd15; cin = 0; #10;
        A = 4'd15; B = 4'd1; cin = 0; #10;
        A = 4'd0; B = 4'd15; cin = 1; #10;
        A = 4'd15; B = 4'd15; cin = 1; #10;

        
        $finish;
    end

endmodule
