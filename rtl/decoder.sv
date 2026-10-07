// Decoder

module decoder #(
    parameter int WIDTH = 8,
    parameter int DEPTH = $clog2(WIDTH)
) (
    input   logic [DEPTH-1:0] addr_i,
    input   logic             en_i,
    output  logic [WIDTH-1:0] out_o
);

    assign out_o = en_i ? ({{(WIDTH-1){1'b0}}, 1'b1} << addr_i) : '0;

endmodule
