// Asynchronous FIFO

// Transferring the data between two independent clock domain.
// The FIFO uses seperate write and read clocks, Gray-coded pointers, and
//  2-flip-flop synchronizers to safely communicate FIFO state information
//  between the two clock domains.

//                      ASYNCHRONOUS FIFO

//              WRITE DOMAIN                 READ DOMAIN
//           +----------------+           +----------------+
//           |                |           |                |
// wr_clk -->|  Write Pointer |           |  Read Pointer  |<-- rd_clk
//           |     Binary     |           |     Binary     |
//           +-------+--------+           +--------+-------+
//                   |                             |
//                   v                             v
//           +----------------+           +----------------+
//           | Gray Conversion|           | Gray Conversion|
//           +-------+--------+           +--------+-------+
//                   |                             |
//                   |                             |
//                   v                             v
//              Synchronizer                  Synchronizer
//                   |                             |
//                   v                             v
//              Read Domain                  Write Domain
//                Logic                        Logic

//                     +------------------+
//                     |       MEM        |
//                     |                  |
//                     | WIDTH x DEPTH    |
//                     +------------------+

// The write pointer is synchronized into the read clock domain, while
//  the read pointer is synchronized into the write clock domain.
// Due to clock domain synchronization latency, full and empty do not 
//  necessarily change immediately after an operation in the opposite
//  clock domain.

// *full*
    // The FIFO is full when the next write pointer reaches the read pointer
    //  with the appropriate wrap-around condition.
    // The next Gray-coded write pointer is compared against the synchronized
    //  read pointer to generate next_full.
    // This allows full to indicate whether accepting the next write would
    //  fill the FIFO.
// *empty*
    // The FIFO is empty when the current read pointer matches the 
    //  synchronized write pointer.
    // Because the write pointer must cross the clock domain synchronizer,
    //  empty can remain asserted for a short period after a new write occurs.


module async_fifo #(
    parameter int WIDTH = 8,    // Width of each FIFO entry
    parameter int DEPTH = 16    // Number of entries in the FIFO
) (
    // Write domain
    input   logic             wr_clk_i,  // Write clock
    input   logic             wr_rstn_i, // Active-low write domain reset
    input   logic             wr_en_i,   // Write request
    input   logic [WIDTH-1:0] wr_data_i, // Data to write
    output  logic             full_o,    // Full flag
    // Read domain
    input   logic             rd_clk_i,  // Read clock
    input   logic             rd_rstn_i, // Acitve-low read domain reset
    input   logic             rd_en_i,   // Write request
    output  logic [WIDTH-1:0] rd_data_o, // Data to write
    output  logic             empty_o    // Empty flag
);

    // DEPTH constraint: DEPTH > 2 and DEPTH power of 2
    generate
        if ((DEPTH <= 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial begin
                $fatal(1, "Error: DEPTH must be > 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
            end
        end
    endgenerate

    localparam int ADDR_WIDTH = $clog2(DEPTH);      // Address width
    localparam int PTR_WIDTH  = $clog2(DEPTH) + 1;  // Pointer width

    logic [    WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0] wr_ptr, rd_ptr;               // Binary pointers
    logic [PTR_WIDTH-1:0] gray_wr_ptr, gray_rd_ptr;     // Gray-coded pointers
    logic [PTR_WIDTH-1:0] wr_sync1, wr_sync2;           // Write synchronizers
    logic [PTR_WIDTH-1:0] rd_sync1, rd_sync2;           // Read synchronizers
    logic [PTR_WIDTH-1:0] next_wr_ptr, next_wr_gray;    // Next write pointers
    logic next_full;    // Next full flag

    // Gray Coded Write Pointer
    assign gray_wr_ptr = wr_ptr ^ (wr_ptr >> 1);

    // Gray-coded write pointer sync
    always_ff @(posedge rd_clk_i or negedge rd_rstn_i) begin : wrptr_to_read
        if (!rd_rstn_i) begin
            wr_sync1 <= '0;
            wr_sync2 <= '0;
        end else begin
            wr_sync1 <= gray_wr_ptr;
            wr_sync2 <= wr_sync1;
        end
    end

    // Next write pointers
    assign next_wr_ptr = wr_ptr + (wr_en_i && !full_o);
    assign next_wr_gray = next_wr_ptr ^ (next_wr_ptr >> 1);

    // Write Side
    always_ff @(posedge wr_clk_i or negedge wr_rstn_i) begin : wr_block
        if (!wr_rstn_i) begin
            wr_ptr <= '0;
            full_o <= 0;
        end else begin
            if (wr_en_i && !full_o) begin
                mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data_i;
            end
            wr_ptr <= next_wr_ptr;
            full_o <= next_full;      // Lookup: *full*
        end
    end

    // Gray Coded Read Pointer
    assign gray_rd_ptr = rd_ptr ^ (rd_ptr >> 1);

    // Gray-coded read pointer sync
    always_ff @(posedge wr_clk_i or negedge wr_rstn_i) begin : rdptr_to_write
        if (!wr_rstn_i) begin
            rd_sync1 <= '0;
            rd_sync2 <= '0;
        end else begin
            rd_sync1 <= gray_rd_ptr;
            rd_sync2 <= rd_sync1;
        end
    end

    // Read Side
    always_ff @(posedge rd_clk_i or negedge rd_rstn_i) begin : rd_block
        if (!rd_rstn_i) begin
            rd_ptr    <= '0;
            rd_data_o <= '0;
        end else begin
            if (rd_en_i && !empty_o) begin
                rd_data_o <= mem[rd_ptr[ADDR_WIDTH-1:0]];
                rd_ptr    <= rd_ptr + 1;
            end
        end
    end

    // Lookup: *full*
    assign next_full    = (next_wr_gray == {~rd_sync2[PTR_WIDTH-1:PTR_WIDTH-2], rd_sync2[PTR_WIDTH-3:0]});
    // Lookup: *empty*
    assign empty_o      = (gray_rd_ptr == wr_sync2) ? 1 : 0;
    
endmodule