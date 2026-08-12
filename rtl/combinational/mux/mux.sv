
module mux #(
    parameter int WIDTH     = 4,
    parameter int INPUTS    = 2**WIDTH
) (
    input   logic   [        WIDTH-1:0] in [INPUTS],
    input   logic   [$clog2(INPUTS)-1:0] sel,
    output  logic   [        WIDTH-1:0] out
);

    assign out = in[sel];

endmodule
