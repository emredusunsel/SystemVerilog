
module comparator #(
    parameter int WIDTH = 8
) (
    input   logic   [WIDTH-1:0] a,
    input   logic   [WIDTH-1:0] b,
    output  logic               eq,
    output  logic               gt,
    output  logic               lt
);
    
    assign eq = (a == b);
    assign gt = (a > b);
    assign lt = (a < b);

endmodule
