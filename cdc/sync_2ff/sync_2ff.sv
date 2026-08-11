
module sync_2ff (
    input   logic   clk,
    input   logic   rstn,
    input   logic   async_in,
    output  logic   sync_out
);

    logic sync1;

    always_ff @(posedge clk or negedge rstn) begin : sync_block
        if (!rstn) begin
            sync_out    <= 0;
            sync1       <= 0;
        end else begin
            sync1       <= async_in;
            sync_out    <= sync1;
        end
    end

endmodule
