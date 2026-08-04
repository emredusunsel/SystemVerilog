
module rca (
    input   logic   [3:0]   a,
    input   logic   [3:0]   b,
    input   logic           cin,
    output  logic   [3:0]   s,
    output  logic           cout
);

    logic [2:0] carry;

    full_adder fa0(
        .a(a[0]),
        .b(b[0]),
        .cin(cin),
        .s(s[0]),
        .cout(carry[0])
    );
    
    full_adder fa1(
        .a(a[1]),
        .b(b[1]),
        .cin(carry[0]),
        .s(s[1]),
        .cout(carry[1])
    );
    
    full_adder fa2(
        .a(a[2]),
        .b(b[2]),
        .cin(carry[1]),
        .s(s[2]),
        .cout(carry[2])
    );

    full_adder fa3(
        .a(a[3]),
        .b(b[3]),
        .cin(carry[2]),
        .s(s[3]),
        .cout(cout)
    );

endmodule
