`timescale 1ps/1ps

module mux_tb;

    logic [2:0] a, b, c, d;
    logic [2:0] e, f, g, h, y;
    logic [2:0] sel;

    mux dut(
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .h(h),
        .sel(sel),
        .y(y)
    );

    initial begin
        //Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, mux_tb);

        //Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  c=%b  d=%b  e=%b  f=%b  g=%b  h=%b  sel=%b  y=%b", 
                $time, a, b, c, d, e, f, g, h, sel, y);

        //Apply test vectors
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b000; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b001; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b010; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b011; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b100; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b101; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b110; #10;
        a = 3'b000; b = 3'b001; c = 3'b010; d = 3'b011;
        e = 3'b100; f = 3'b101; g = 3'b110; h = 3'b111; sel=3'b111; #10;

        $finish;
    end

endmodule
