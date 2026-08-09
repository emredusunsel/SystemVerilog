
module dff (
    input   logic   clk,
    input   logic   rstn,
    input   logic   d,
    output  logic   q,
    output  logic   qn
);

    always_ff @(posedge clk or negedge rstn) begin : dflipflop
        if(!rstn)
            q <= '0;
        else
            q <= d;
    end

    assign qn = ~q;

endmodule
