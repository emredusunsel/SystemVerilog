
module barrel #(
    parameter int WIDTH = 8
) (
    input   logic   [        WIDTH-1:0] data,
    input   logic   [$clog2(WIDTH)-1:0] shamt,
    output  logic   [        WIDTH-1:0] result
);

    logic   [WIDTH-1:0] stage   [$clog2(WIDTH)];

    genvar i;

    generate
        assign stage[0] = shamt[0] ? {data[0], data[WIDTH-1:1]} : data;
        for (i = 1; i < $clog2(WIDTH); i++) begin
            assign stage[i] = shamt[i] ? {stage[i-1][(2**i-1):0], stage[i-1][WIDTH-1:2**i]} :
                                stage[i-1];
        end
    endgenerate

    assign result = stage[$clog2(WIDTH)-1];

endmodule
