
module async_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    // write domain
    input   logic               wr_clk,
    input   logic               wr_rstn,
    input   logic               wr_en,
    input   logic   [WIDTH-1:0] wr_data,
    output  logic               full,
    // read domain
    input   logic               rd_clk,
    input   logic               rd_rstn,
    input   logic               rd_en,
    output  logic   [WIDTH-1:0] rd_data,
    output  logic               empty
);

    // DEPTH constraint
    generate
        if ((DEPTH <= 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial begin
                $fatal(1, "Error: DEPTH must be > 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
            end
        end
    endgenerate

    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int PTR_WIDTH  = $clog2(DEPTH) + 1;

    logic [        WIDTH-1:0] mem [DEPTH];
    logic [    PTR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [    PTR_WIDTH-1:0] gray_wr_ptr, gray_rd_ptr;
    logic [    PTR_WIDTH-1:0] wr_sync1, wr_sync2;
    logic [    PTR_WIDTH-1:0] rd_sync1, rd_sync2;
    logic [    PTR_WIDTH-1:0] next_wr_ptr, next_wr_gray;
    logic next_full;

    // Gray Coded Write Pointer
    assign gray_wr_ptr = wr_ptr ^ (wr_ptr >> 1);

    // GCWP sync
    always_ff @(posedge rd_clk or negedge rd_rstn) begin : wrptr_to_read
        if (!rd_rstn) begin
            wr_sync1 <= '0;
            wr_sync2 <= '0;
        end else begin
            wr_sync1 <= gray_wr_ptr;
            wr_sync2 <= wr_sync1;
        end
    end

    // next write pointers
    assign next_wr_ptr = wr_ptr + (wr_en && !full);
    assign next_wr_gray = next_wr_ptr ^ (next_wr_ptr >> 1);

    // Write Side
    always_ff @(posedge wr_clk or negedge wr_rstn) begin : wr_block
        if (!wr_rstn) begin
            wr_ptr      <= '0;
            full        <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            end
            wr_ptr <= next_wr_ptr;
            full <= next_full;
        end
    end

    // Gray Coded Read Pointer
    assign gray_rd_ptr = rd_ptr ^ (rd_ptr >> 1);

    // GCRP sync
    always_ff @(posedge wr_clk or negedge wr_rstn) begin : rdptr_to_write
        if (!wr_rstn) begin
            rd_sync1 <= '0;
            rd_sync2 <= '0;
        end else begin
            rd_sync1 <= gray_rd_ptr;
            rd_sync2 <= rd_sync1;
        end
    end

    // Read Side
    always_ff @(posedge rd_clk or negedge rd_rstn) begin : rd_block
        if (!rd_rstn) begin
            rd_ptr  <= '0;
            rd_data <= '0;
        end else begin
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr  <= rd_ptr + 1;
            end
        end
    end

    assign next_full    = (next_wr_gray == {~rd_sync2[PTR_WIDTH-1:PTR_WIDTH-2], rd_sync2[PTR_WIDTH-3:0]});
    assign empty        = (gray_rd_ptr == wr_sync2) ? 1 : 0;
    
endmodule