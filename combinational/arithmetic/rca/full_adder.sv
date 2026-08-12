
module full_adder (
    input   logic   a,
    input   logic   b,
    input   logic   cin,
    output  logic   s,
    output  logic   cout
);

    assign s = cin ^ (a ^ b);
    assign cout = (cin & (a ^ b)) | (a & b);

endmodule
