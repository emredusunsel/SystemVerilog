
module dff #(
    parameter int WIDTH = 4
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               en,
    input   logic   [WIDTH-1:0] d,
    output  logic   [WIDTH-1:0] q
);

    always_ff @(posedge clk or negedge rstn) begin : dflipflop
        if (!rstn)
            q <= '0;
        else if (en)
            q <= d;        
    end

endmodule
