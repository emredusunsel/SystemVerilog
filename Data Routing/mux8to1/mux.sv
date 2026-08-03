
module mux (
    input   logic   [2:0]   a,
    input   logic   [2:0]   b,
    input   logic   [2:0]   c,
    input   logic   [2:0]   d,
    input   logic   [2:0]   e,
    input   logic   [2:0]   f,
    input   logic   [2:0]   g,
    input   logic   [2:0]   h,
    input   logic   [2:0]   sel,
    output  logic   [2:0]   y
);
    
    always_comb begin : mux8to1
        case (sel)
            3'b000: y = a;
            3'b001: y = b;
            3'b010: y = c;
            3'b011: y = d;
            3'b100: y = e;
            3'b101: y = f;
            3'b110: y = g;
            3'b111: y = h; 
            default: y = 3'b000;
        endcase
    end

endmodule
