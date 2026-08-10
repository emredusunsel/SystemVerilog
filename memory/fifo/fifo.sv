
module fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic   [WIDTH-1:0] data_i,
    input   logic               wr_en,
    input   logic               rd_en,
    output  logic   [WIDTH-1:0] data_o,
    output  logic               empty,
    output  logic               full
);

    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0] count;
    logic [WIDTH-1:0] fifo_mem [DEPTH];

    always_ff @(posedge clk or negedge rstn) begin : fifo_control
        if (!rstn) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            data_o <= '0;
        end else begin
            // Write
            if (wr_en && !full) begin
                fifo_mem[wr_ptr] <= data_i;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read
            if (rd_en && !empty) begin
                data_o <= fifo_mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Update count
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    assign full = (count == DEPTH);
    assign empty = (count == 0);

endmodule
