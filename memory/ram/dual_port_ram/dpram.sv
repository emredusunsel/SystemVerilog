
module dpram #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    input   logic                       clk,
    input   logic                       rstn,
    input   logic                       wr_en,
    input   logic   [$clog2(DEPTH)-1:0] wr_addr,
    input   logic   [        WIDTH-1:0] wr_data,
    input   logic                       rd_en,
    input   logic   [$clog2(DEPTH)-1:0] rd_addr,
    output  logic   [        WIDTH-1:0] rd_data
);
    
    // WIDTH constraint
    generate
        if ((WIDTH < 1)) begin
            initial
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
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
            rd_data <= '0;
        else begin
            if (wr_addr != rd_addr) begin
                if (wr_en)
                    mem[wr_addr] <= wr_data;
                if (rd_en)
                    rd_data <= mem[rd_addr];
            end else begin
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
