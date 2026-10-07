`timescale 1ps/1ps

module mux_tb;

    localparam WIDTH = 4;
    localparam INPUTS = 2**WIDTH;

    logic [WIDTH-1:0] in[INPUTS];
    logic [$clog2(INPUTS)-1:0] sel;
    logic [WIDTH-1:0] out;

    mux #(
        .WIDTH(WIDTH), .INPUTS(INPUTS)
    ) dut (
        .in (in),
        .sel(sel),
        .out(out)
    );

    initial begin
        $monitor("%b", out);

        for (int i = 0; i < 2**WIDTH; i ++) begin
            in[i] = i;
        end

        for (int j = 0; j < INPUTS; j++) begin
            sel = j;
            #10;
        end

        $finish;
    end


endmodule
