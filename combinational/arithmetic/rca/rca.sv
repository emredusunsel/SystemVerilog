
module rca #(
    parameter int WIDTH = 4
) (
    input   logic   [WIDTH-1:0] a,
    input   logic   [WIDTH-1:0] b,
    input   logic               cin,
    output  logic   [WIDTH-1:0] s,
    output  logic               cout
);

    logic [WIDTH:0] carry;

    genvar i;

    generate
        for (i = 0; i < WIDTH; i++) begin
            full_adder fa(
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),
                .s(s[i]),
                .cout(carry[i + 1])
            );
        end
    endgenerate

    assign carry[0] = cin;
    assign cout = carry[WIDTH];

endmodule
