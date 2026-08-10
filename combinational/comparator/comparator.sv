
module comparator (
    input   logic   [7:0]   a,
    input   logic   [7:0]   b,
    output  logic           eq,
    output  logic           gt,
    output  logic           lt
);

    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);

endmodule
