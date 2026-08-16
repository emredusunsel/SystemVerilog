
module spram #(
    parameter int WIDTH = 8,        // Number of bits per memory word   >=1
    parameter int DEPTH = 16       // Number of addressable words      >=2
) (
    input   logic                     clk,
    input   logic                     rstn,
    input   logic                     en,
    input   logic                     we,
    input   logic [$clog2(DEPTH)-1:0] addr,
    input   logic [        WIDTH-1:0] wr_data,
    output  logic [        WIDTH-1:0] rd_data
);

    // WIDTH constraint
    generate
        if ((WIDTH < 1)) begin
            initial begin
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
            end
        end
    endgenerate

    // DEPTH constraint
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
            rd_data     <= '0;
        else begin
            if (en && we)
                mem[addr] <= wr_data;
            else if (en && !we)
                rd_data <= mem[addr];
        end
    end
    
endmodule