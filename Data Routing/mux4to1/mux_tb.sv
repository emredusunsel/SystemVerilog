`timescale 1ps/1ps

module mux_tb;

    logic a, b, c, d, y;
    logic [1:0] sel;

    mux dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .y(y)
    );

    initial begin
        //Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, mux_tb);

        //Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  c=%b  d=%b sel=%b  y=%b", $time, a, b, c, d, sel, y);

        //Apply test vectors
        a = 1; b = 0; c = 0; d = 0; sel=2'b00; #10;
        a = 1; b = 0; c = 0; d = 0; sel=2'b01; #10;
        a = 1; b = 0; c = 0; d = 0; sel=2'b10; #10;
        a = 1; b = 0; c = 0; d = 0; sel=2'b11; #10;


        a = 0; b = 1; c = 0; d = 0; sel=2'b00; #10;
        a = 0; b = 1; c = 0; d = 0; sel=2'b01; #10;
        a = 0; b = 1; c = 0; d = 0; sel=2'b10; #10;
        a = 0; b = 1; c = 0; d = 0; sel=2'b11; #10;


        a = 0; b = 0; c = 1; d = 0; sel=2'b00; #10;
        a = 0; b = 0; c = 1; d = 0; sel=2'b01; #10;
        a = 0; b = 0; c = 1; d = 0; sel=2'b10; #10;
        a = 0; b = 0; c = 1; d = 0; sel=2'b11; #10;


        a = 0; b = 0; c = 0; d = 1; sel=2'b00; #10;
        a = 0; b = 0; c = 0; d = 1; sel=2'b01; #10;
        a = 0; b = 0; c = 0; d = 1; sel=2'b10; #10;
        a = 0; b = 0; c = 0; d = 1; sel=2'b11; #10;

        $finish;
    end

endmodule
