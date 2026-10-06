// Ripple Carry Adder

module rca #(
    parameter int WIDTH = 4
) (
    input   logic   [WIDTH-1:0] a,      // First operand
    input   logic   [WIDTH-1:0] b,      // Second operand
    input   logic               cin,    // Initial carry-in
    output  logic   [WIDTH-1:0] s,      // Sum
    output  logic               cout    // Final carry-out
);

    logic [WIDTH:0] carry;  // Carry propagation wire

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
