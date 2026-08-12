
typedef enum logic [2:0] {
    ADD_OP,
    SUB_OP,
    AND_OP,
    OR_OP,
    XOR_OP,
    NOT_OP,
    SHL_OP,
    SHR_OP
} alu_op_t;

module alu #(
    parameter int WIDTH = 8
) (
    input   logic   [WIDTH-1:0] a,
    input   logic   [WIDTH-1:0] b,
    input   alu_op_t            op,
    output  logic   [WIDTH-1:0] out,
    output  logic               zero,
    output  logic               carry,
    output  logic               of,         // overflow
    output  logic               neg         // negative
);

    logic [WIDTH:0] temp;

    always_comb begin : alu_operations
        out     = '0;
        carry   = 0;
        of      = 0;
        temp    = '0;

        case (op)
            ADD_OP: begin
                temp    = {1'b0, a} + {1'b0, b};
                out     = temp[WIDTH-1:0];
                carry   = temp[WIDTH];
                of      = (a[WIDTH-1] == b[WIDTH-1]) &&
                        (out[WIDTH-1] != a[WIDTH-1]);
            end
            SUB_OP: begin
                temp    = {1'b0, a} + {1'b0, ~b} + 1'b1;
                out     = temp[WIDTH-1:0];
                carry   = temp[WIDTH];
                of      = (a[WIDTH-1] != b[WIDTH-1]) &&
                        (out[WIDTH-1] != a[WIDTH-1]);
            end
            AND_OP: out = a & b;
            OR_OP:  out = a | b;
            XOR_OP: out = a ^ b;
            NOT_OP: out = ~a;
            SHL_OP: out = (a << b[$clog2(WIDTH)-1:0]);
            SHR_OP: out = (a >> b[$clog2(WIDTH)-1:0]);
            default: begin
                out     = '0;
                carry   = 0;
                of      = 0;
                temp    = '0;
            end
        endcase
    end

    assign zero = (out == 0);
    assign neg  = out[WIDTH-1];

endmodule
