
module dff (
    input   logic           clk,
    input   logic           rstn,
    input   logic   [3:0]   d,
    output  logic   [3:0]   q
);

    always_ff @(posedge clk or negedge rstn) begin : dflipflop
        if(!rstn)
            q <= '0;
        else
            q <= d;
    end

endmodule
