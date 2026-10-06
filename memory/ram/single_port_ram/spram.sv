// Single-Port RAM

// Memory uses a signle clock and suppoerts either a write or a read
//  operation on each clock cycle.
// Reset is synchronous and doesn't clear mem.

// | en | we | Operation |
// |----|----|-----------|
// | 0  | X  | No op     |
// | 1  | 0  | Read      |
// | 1  | 1  | Write     |



module spram #(
    parameter int WIDTH = 8,       // Number of bits per memory word
    parameter int DEPTH = 16       // Number of addressable words
) (
    input   logic                     clk,
    input   logic                     rstn,
    input   logic                     en,
    input   logic                     we,       // Write operation
    input   logic [$clog2(DEPTH)-1:0] addr,     // Memory address
    input   logic [        WIDTH-1:0] wr_data,  // Write data
    output  logic [        WIDTH-1:0] rd_data   // Read data
);

    // WIDTH constraint: WIDTH >= 1
    generate
        if ((WIDTH < 1)) begin
            initial begin
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
            end
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

    always_ff @(posedge clk) begin : ram_block
        if (!rstn)
            rd_data     <= '0;
        else begin
            if (en && we)
                mem[addr] <= wr_data;
            else if (en && !we)
                rd_data <= mem[addr];
        end
    end
    
endmodule