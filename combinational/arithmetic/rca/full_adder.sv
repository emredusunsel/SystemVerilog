
module full_adder (
    input   logic   a,      // First operand
    input   logic   b,      // Seconde operand
    input   logic   cin,    // Carry-in
    output  logic   s,      // Sum
    output  logic   cout    // Carry-out
);

    assign s = cin ^ (a ^ b);
    assign cout = (cin & (a ^ b)) | (a & b);

endmodule
