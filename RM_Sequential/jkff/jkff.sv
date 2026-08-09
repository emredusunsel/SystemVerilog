
module jkff (
    input   logic   clk,
    input   logic   rstn,
    input   logic   en,
    input   logic   j,
    input   logic   k,
    output  logic   q
);
    
    always_ff @(posedge clk or negedge rstn) begin : jk_flipflop
        if (!rstn)
            q <= 0;
        else if (en) begin
            case ({j,k})
                2'b00: q <= q;
                2'b01: q <= 0;
                2'b10: q <= 1;
                2'b11: q <= ~q;
                default: ;
            endcase
        end
    end

endmodule
