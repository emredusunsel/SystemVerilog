// Counter

module counter #(
    parameter int WIDTH = 4
) (
    input   logic             clk_i,
    input   logic             rstn_i,
    input   logic             en_i,
    input   logic             dir_i,   // 0: up count, 1: down count
    output  logic [WIDTH-1:0] q_o
);

    always_ff @(posedge clk_i or negedge rstn_i) begin : count_ff
        if (!rstn_i)
            q_o <= '0;
        else if (en_i) begin
            if (!dir_i)
                q_o <= q_o + 1'b1;
            else
                q_o <= q_o - 1'b1;
        end
    end

endmodule
