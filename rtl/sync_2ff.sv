// 2-Flip-Flop Synchronizer

module sync_2ff (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic async_i,
    output logic sync_o
);

    logic sync1;

    always_ff @(posedge clk_i or negedge rstn_i) begin : sync_block
        if (!rstn_i) begin
            sync_o <= 0;
            sync1  <= 0;
        end else begin
            sync1  <= async_i;
            sync_o <= sync1;
        end
    end

endmodule
