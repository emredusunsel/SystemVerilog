// Ripple Carry Adder

module rca #(
    parameter int WIDTH = 4
) (
    input   logic [WIDTH-1:0] a_i,    // First operand
    input   logic [WIDTH-1:0] b_i,    // Second operand
    input   logic             c_i,    // Initial carry-in
    output  logic [WIDTH-1:0] s_o,    // Sum
    output  logic             c_o     // Final carry-out
);

    logic [WIDTH:0] c_w;  // Carry propagation wire

    generate
        for (genvar i = 0; i < WIDTH; i++) begin
            full_adder fa_u(
                .a_i(a_i[i]),
                .b_i(b_i[i]),
                .c_i(c_w[i]),
                .s_o(s_o[i]),
                .c_o(c_w[i + 1])
            );
        end
    endgenerate

    assign c_w[0] = c_i;
    assign c_o    = c_w[WIDTH];

endmodule
