// First-In, First-Out

// Active-low asynchronous reset.
// A simultaneous valid read and write keeps occupancy unchanged.

module fifo #(
    parameter int WIDTH = 8,    // Width of each stored word
    parameter int DEPTH = 16    // Number of enries in the FIFO
) (
    input   logic             clk_i,
    input   logic             rstn_i,
    input   logic [WIDTH-1:0] data_i,  // Data to write
    input   logic             wr_en_i, // Write enable
    input   logic             rd_en_i, // Read enable
    output  logic [WIDTH-1:0] data_o,  // Data read from FIFO
    output  logic             empty_o, // Empty flag
    output  logic             full_o   // Full flag
);

    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;   // Pointers
    logic [$clog2(DEPTH):0] count;              // Occupancy counter
    logic [WIDTH-1:0] fifo_mem [0:DEPTH-1];

    always_ff @(posedge clk_i or negedge rstn_i) begin : fifo_control
        if (!rstn_i) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
            data_o <= '0;
        end else begin
            // Write
            if (wr_en_i && !full_o) begin
                fifo_mem[wr_ptr] <= data_i;
                wr_ptr <= wr_ptr + 1'b1;
            end

            // Read
            if (rd_en_i && !empty_o) begin
                data_o <= fifo_mem[rd_ptr];
                rd_ptr <= rd_ptr + 1'b1;
            end

            // Update count
            case ({wr_en_i && !full_o, rd_en_i && !empty_o})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase
        end
    end

    assign full_o  = (count == DEPTH);
    assign empty_o = (count == 0);

endmodule
