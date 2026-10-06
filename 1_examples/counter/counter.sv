
module counter #(
    parameter int WIDTH = 4
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               en,
    input   logic               dir,   // 0: up count, 1: down count
    output  logic   [WIDTH-1:0] q
);

    always_ff @(posedge clk or negedge rstn) begin : count_ff
        if (!rstn)
            q <= '0;
        else if (en) begin
            if (!dir)
                q <= q + 1'b1;
            else
                q <= q - 1'b1;
        end
    end

endmodule
