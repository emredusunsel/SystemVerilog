
module decoder #(
    parameter int WIDTH = 8,
    parameter int DEPTH = $clog2(WIDTH)
) (
    input   logic   [DEPTH-1:0] addr,
    input   logic               en,
    output  logic   [WIDTH-1:0] y
);

    assign y = en ? ({{(WIDTH-1){1'b0}}, 1'b1} << addr) : '0;

endmodule
