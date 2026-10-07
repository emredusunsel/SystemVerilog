// Full Adder

module full_adder (
    input   logic   a_i,    // First operand
    input   logic   b_i,    // Second operand
    input   logic   c_i,    // Carry-in
    output  logic   s_o,    // Sum
    output  logic   c_o     // Carry-out
);

    assign s_o = c_i ^ (a_i ^ b_i);
    assign c_o = (c_i & (a_i ^ b_i)) | (a_i & b_i);

endmodule
