`timescale 1ps/1ps

module mux_tb;

    logic a, b, sel, y;

    mux dut(
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    initial begin
        //Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, mux_tb);

        //Print values whenever they change
        $monitor("Time=%0t  a=%b  b=%b  sel=%b  y=%b", $time, a, b, sel, y);

        //Apply test vectors
        a = 1; b = 0; sel=0; #10;
        a = 1; b = 0; sel=1; #10;
        a = 0; b = 1; sel=0; #10;
        a = 0; b = 1; sel=1; #10;

        $finish;
    end

endmodule
