// D Flip-Flop

module dff (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic en_i,
    input  logic d_i,
    output logic q_o
);

    always_ff @(posedge clk_i or negedge rstn_i) begin : dflipflop
        if (!rstn_i)
            q_o <= '0;
        else if (en_i)
            q_o <= d_i;
    end

endmodule
