// ALU

// WIDTH can take any value so keep track of SHAMT_WIDTH.

module alu #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] a_i,      // First operand
    input  logic [WIDTH-1:0] b_i,      // Second operand
    input  logic [      3:0] op_i,     // Operation selection
    output logic [WIDTH-1:0] out_o,    // Operation result
    output logic             zero_o,   // Zero flag
    output logic             carry_o,  // Carry flag
    output logic             of_o,     // Overflow flag
    output logic             neg_o     // Negative flag
);

    // Shamt width constraint
    localparam int SHAMT_WIDTH = (WIDTH > 1) ? $clog2(WIDTH) : 1;

    // Opeartion encoding
    localparam logic [3:0] ADD_OP  = 4'b0000;
    localparam logic [3:0] SUB_OP  = 4'b0001;
    localparam logic [3:0] AND_OP  = 4'b0010;
    localparam logic [3:0] OR_OP   = 4'b0011;
    localparam logic [3:0] XOR_OP  = 4'b0100;
    localparam logic [3:0] SLL_OP  = 4'b0101;
    localparam logic [3:0] SRL_OP  = 4'b0110;
    localparam logic [3:0] SRA_OP  = 4'b0111;
    localparam logic [3:0] SLT_OP  = 4'b1000;
    localparam logic [3:0] SLTU_OP = 4'b1001;

    logic [        WIDTH:0] temp;     // +1 bit wide => carry calculation
    logic [SHAMT_WIDTH-1:0] shamt;    // shift amount

    always_comb begin : alu_operations
        out_o   = '0;
        carry_o =  0;
        of_o    =  0;
        temp    = '0;

        case (op_i)
            ADD_OP: begin                      
                temp    = {1'b0, a_i} + {1'b0, b_i};
                out_o   = temp[WIDTH-1:0];
                carry_o = temp[WIDTH];
                of_o    = (a_i[WIDTH-1] == b_i[WIDTH-1]) &&
                          (out_o[WIDTH-1] != a_i[WIDTH-1]);
            end
            SUB_OP: begin                       
                temp    = {1'b0, a_i} + {1'b0, ~b_i} + 1'b1;
                out_o   = temp[WIDTH-1:0];
                carry_o = temp[WIDTH];
                of_o    = (a_i[WIDTH-1] != b_i[WIDTH-1]) &&
                          (out_o[WIDTH-1] != a_i[WIDTH-1]);
            end
            AND_OP: out_o = a_i & b_i;                
            OR_OP:  out_o = a_i | b_i;               
            XOR_OP: out_o = a_i ^ b_i;                
            SLL_OP: out_o = a_i << shamt;           
            SRL_OP: out_o = a_i >> shamt;           
            SRA_OP: out_o = $signed(a_i) >>> shamt; 
            SLT_OP: begin                       
                if ($signed(a_i) < $signed(b_i))
                    out_o = {{(WIDTH-1){1'b0}}, 1'b1};
                else
                    out_o = '0;
            end
            SLTU_OP: begin
                if (a_i < b_i)
                    out_o = {{(WIDTH-1){1'b0}}, 1'b1};
                else
                    out_o = '0;
            end
            default: begin
                out_o   = '0;
                carry_o = 0;
                of_o    = 0;
                temp    = '0;
            end
        endcase
    end

    assign shamt  = b_i[SHAMT_WIDTH-1:0];
    assign zero_o = (out_o == '0);
    assign neg_o  = out_o[WIDTH-1];

endmodule
