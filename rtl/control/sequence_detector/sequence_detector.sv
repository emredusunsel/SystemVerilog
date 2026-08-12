
module sequence_detector #(
    parameter int SEQ_LEN = 4,
    parameter logic [SEQ_LEN-1:0] SEQ = 4'b1011
) (
    input   logic   clk,
    input   logic   rstn,
    input   logic   in,
    output  logic   out
);

    logic [SEQ_LEN-1:0] seq_mem;

    always_ff @(posedge clk or negedge rstn) begin : seq_block
        if (!rstn) begin
            seq_mem <= '0;
        end else begin
            seq_mem <= {seq_mem[SEQ_LEN-2:0], in};
        end
    end

    assign out = (seq_mem == SEQ) ? 1 : 0;

endmodule
