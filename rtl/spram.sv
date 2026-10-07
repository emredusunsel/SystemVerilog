// Single-Port RAM

// Memory uses a signle clock and suppoerts either a write or a read
//  operation on each clock cycle.
// Reset is synchronous and doesn't clear mem.

// | en_i | we_i | Operation |
// |------|------|-----------|
// | 0    | X    | No op     |
// | 1    | 0    | Read      |
// | 1    | 1    | Write     |

`include "../include/param_checks.svh"

module spram #(
    parameter int WIDTH = 8,       // Number of bits per memory word
    parameter int DEPTH = 16       // Number of addressable words
) (
    input   logic                     clk_i,
    input   logic                     rstn_i,
    input   logic                     en_i,
    input   logic                     we_i,      // Write operation
    input   logic [$clog2(DEPTH)-1:0] addr_i,    // Memory address
    input   logic [        WIDTH-1:0] wr_data_i, // Write data
    output  logic [        WIDTH-1:0] rd_data_o  // Read data
);

    // WIDTH constraint: WIDTH >= 1
    `CHECK_GREATER_EQUAL(WIDTH, 1)

    // DEPTH constraint: DEPTH >= 2 and DEPTH is power of 2
    `CHECK_GREATER_EQUAL(DEPTH, 2)
    `CHECK_POWER_OF_TWO(DEPTH)

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk_i) begin : ram_block
        if (!rstn_i)
            rd_data_o <= '0;
        else begin
            if (en_i && we_i)
                mem[addr_i] <= wr_data_i;
            else if (en_i && !we_i)
                rd_data_o <= mem[addr_i];
        end
    end
    
endmodule