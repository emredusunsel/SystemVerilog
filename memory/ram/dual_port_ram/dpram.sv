// Dual-Port RAM

// Seperate read and write enables, allowing read and write
//  operations to occur in the same clock cycle.
// Reset is synchronous and doesn't reset the mem contents.
// Independent read and write addresses.

// | wr_en | rd_en | Address Relation | Operation                         |
// |-------|-------|------------------|-----------------------------------|
// | 0     | 0     | Any              | No operation                      |
// | 1     | 0     | Any              | Write                             |
// | 0     | 1     | Any              | Read                              |
// | 1     | 1     | Different        | Read and write simultaneously     |
// | 1     | 1     | Same             | Write new data and return wr_data |

// *same addr operation*
    // Write only:
        // The new data is written to selected address.
    // Read only:
        // The existing memory contents are returned through rd_data.
    // Simultaneous Read and Write:
        // Write first, newly written value is returned on rd_data.



module dpram #(
    parameter int WIDTH = 8,    // Number of bits per memory word
    parameter int DEPTH = 16    // Number of memory locations
) (
    input   logic                       clk,
    input   logic                       rstn,
    input   logic                       wr_en,      // Write enable
    input   logic   [$clog2(DEPTH)-1:0] wr_addr,    // Write address
    input   logic   [        WIDTH-1:0] wr_data,    // Write data
    input   logic                       rd_en,      // Read enable
    input   logic   [$clog2(DEPTH)-1:0] rd_addr,    // Read address
    output  logic   [        WIDTH-1:0] rd_data     // Read data
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

    logic [WIDTH-1:0] mem [DEPTH];

    always_ff @(posedge clk) begin : ram_block
        if (!rstn)
            rd_data <= '0;
        else begin
            if (wr_addr != rd_addr) begin
                if (wr_en)
                    mem[wr_addr] <= wr_data;
                if (rd_en)
                    rd_data <= mem[rd_addr];
            end else begin
                // Lookup: *same addr operation*
                if (wr_en && !rd_en)
                    mem[wr_addr] <= wr_data;
                else if (!wr_en && rd_en)
                    rd_data <= mem[rd_addr];
                else if (wr_en && rd_en) begin
                    mem[wr_addr] <= wr_data;
                    rd_data <= wr_data;
                end
            end
        end
    end

endmodule
