// Dual-Port RAM

// Seperate read and write enables, allowing read and write
//  operations to occur in the same clock cycle.
// Reset is synchronous and doesn't reset the mem contents.
// Independent read and write addresses.

// | wr_en_i | rd_en_i | Address Relation | Operation                           |
// |---------|---------|------------------|-------------------------------------|
// | 0       | 0       | Any              | No operation                        |
// | 1       | 0       | Any              | Write                               |
// | 0       | 1       | Any              | Read                                |
// | 1       | 1       | Different        | Read and write simultaneously       |
// | 1       | 1       | Same             | Write new data and return wr_data_i |

// *same addr operation*
    // Write only:
        // The new data is written to selected address.
    // Read only:
        // The existing memory contents are returned through rd_data_o.
    // Simultaneous Read and Write:
        // Write first, newly written value is returned on rd_data_o.



module dpram #(
    parameter int WIDTH = 8,    // Number of bits per memory word
    parameter int DEPTH = 16    // Number of memory locations
) (
    input   logic                     clk_i,
    input   logic                     rstn_i,
    input   logic                     wr_en_i,   // Write enable
    input   logic [$clog2(DEPTH)-1:0] wr_addr_i, // Write address
    input   logic [        WIDTH-1:0] wr_data_i, // Write data
    input   logic                     rd_en_i,   // Read enable
    input   logic [$clog2(DEPTH)-1:0] rd_addr_i, // Read address
    output  logic [        WIDTH-1:0] rd_data_o  // Read data
);
    
    // WIDTH constraint: WIDTH >= 1
    generate
        if ((WIDTH < 1)) begin
            initial
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
        end
    endgenerate

    // DEPTH constraint: DEPTH >= 2 and DEPTH is power of 2
    generate
        if ((DEPTH < 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial
                $fatal(1, "Error: DEPTH must be > 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
        end
    endgenerate

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk_i) begin : ram_block
        if (!rstn_i)
            rd_data_o <= '0;
        else begin
            if (wr_addr_i != rd_addr_i) begin
                if (wr_en_i)
                    mem[wr_addr_i] <= wr_data_i;
                if (rd_en_i)
                    rd_data_o <= mem[rd_addr_i];
            end else begin
                // Lookup: *same addr operation*
                if (wr_en_i && !rd_en_i)
                    mem[wr_addr_i] <= wr_data_i;
                else if (!wr_en_i && rd_en_i)
                    rd_data_o <= mem[rd_addr_i];
                else if (wr_en_i && rd_en_i) begin
                    mem[wr_addr_i] <= wr_data_i;
                    rd_data_o <= wr_data_i;
                end
            end
        end
    end

endmodule
