
module dff (
    input   logic   clk,
    input   logic   rstn,
    input   logic   en,
    input   logic   d,
    output  logic   q
);

    always_ff @(posedge clk or negedge rstn) begin : dflipflop
        if (!rstn)
            q <= '0;
        else if (en)
            q <= d;        
    end

endmodule
