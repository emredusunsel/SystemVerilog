// Detects a predefined bit pattern in a serial input stream.
// Comparison is continuous.
// Overlap is naturally supported.

// *ff block*
    // Module stores the most recent SEQ_LEN amount of bits in a
    //  shift register and sets out HIGH when they match the
    //  configured PATTERN.
    // At each clock edge, seq_mem is assigned to the 
    //  previous seq_mem shifted left and input in's value 
    //  is set to be its LSB.
    // OR
    //  current_seq_mem <= (prev_seq_mem << 1; prev_seq_mem[0]) == in;

module sequence_detector #(
    parameter int                 SEQ_LEN = 4,
    parameter logic [SEQ_LEN-1:0] PATTERN = 4'b1011
) (
    input   logic   clk,
    input   logic   rstn,
    input   logic   in,
    output  logic   out
);

    logic [SEQ_LEN-1:0] seq_mem;

    // Lookup: *ff block*
    always_ff @(posedge clk or negedge rstn) begin : seq_block
        if (!rstn) begin
            seq_mem <= '0;
        end else begin
            seq_mem <= {seq_mem[SEQ_LEN-2:0], in};
        end
    end

    assign out = (seq_mem == PATTERN) ? 1 : 0;

endmodule
