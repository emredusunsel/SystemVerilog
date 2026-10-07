// Multiplexer

module mux #(
    parameter int WIDTH     = 4,
    parameter int INPUTS    = 2**WIDTH
) (
    input  logic [         WIDTH-1:0] in_i [0:INPUTS-1],
    input  logic [$clog2(INPUTS)-1:0] sel_i,
    output logic [         WIDTH-1:0] out_o
);

    assign out_o = in_i[sel_i];

endmodule
