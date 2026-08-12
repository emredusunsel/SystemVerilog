
typedef enum logic [3:0] {
    ADD_OP,
    SUB_OP,
    AND_OP,
    OR_OP,
    XOR_OP,
    SLL_OP,
    SRL_OP,
    SRA_OP,
    SLT_OP,
    SLTU_OP
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

    logic [          WIDTH:0] temp;
    logic [$clog2(WIDTH)-1:0] shamt;

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
            SLL_OP: out = a << shamt;
            SRL_OP: out = a >> shamt;
            SRA_OP: out = $signed(a) >>> shamt;
            SLT_OP: begin
                if ($signed(a) < $signed(b))
                    out = {{(WIDTH-1){1'b0}}, 1'b1};
                else
                    out = '0;
            end
            SLTU_OP: begin
                if (a < b)
                    out = {{(WIDTH-1){1'b0}}, 1'b1};
                else
                    out = '0;
            end
            default: begin
                out     = '0;
                carry   = 0;
                of      = 0;
                temp    = '0;
            end
        endcase
    end

    assign shamt = b[$clog2(WIDTH)-1:0];
    assign zero = (out == 0);
    assign neg  = out[WIDTH-1];

endmodule
