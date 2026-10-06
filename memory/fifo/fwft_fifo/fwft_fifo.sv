// First-Word Fall-Through FIFO

// The first stored word immediately available on rd_data without
//  requiring a read operation to load it.
// Active-low asynchronous reset.
// Read opeariton advances the read pointer and exposed the next FIFO word.
// Empty: No valid data available.
// Partially full: Data available for reading.
// Full: No additional writes accepted.
// wr_ptr points to the next write location.
// rd_ptr points to the current read location.
// rd_en means consume data.
// empty means all data are consumed.
// Simultaneous Read and Write supported.

// *read write*
    // While both rd_en and wr_en is asserted, if;
    //      Non-Empty FIFO:
    //          Existing word is consumed while the new word is added.
    //          Occupancy remains unchanged.
    //          Pointers increment.
    //      Empty FIFO:
    //          The new data is accepted, but the newly written word is
    //           not consumed by the same-cycle read request.
    //          Write is treated as the first valid FIFO entry.
    //          Empty turns LOW. empty -> 0
    //          Count increments. count -> 1
    //          Ensures that a read request cannot consume data that was not
    //           already available at the beginning of the cycle.
// *output*
    // rd_data = empty ? previous_read_location : current_read_location
    // When non-empty, rd_data directly reflects the memory location addressed
    //  by rd_ptr.
    // When FIFO becomes empty after the final read, the previous memory location
    //  is selected so that the output retains the last stored word instead of
    //  becoming and invalid memory location.
// *full*
    // The FIFO is full when the write and read pointers have the same mmemory
    //  address but different wrap bits.
    // This corresponds to the FIFO containing DEPTH number of entries.
// *empty* No-Lookup
    // Empty flag is updated based on the current FIFO occupancy and read/write
    //  operations.
    // After the first succesful write into an empty FIFO, empty = 0,
    //  and the newly written word becomes available through rd_data.
    // Even though the word is immediately visible on the output, empty is not
    //  asserted until rd_en is asserted. rd_en means consume data, empty means
    //  all data are consumed.

`timescale 1ps/1ps

module fwft_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16        // >= 2 and power of two
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               wr_en,      // Write enable
    input   logic   [WIDTH-1:0] wr_data,    // Data to be written
    input   logic               rd_en,      // Read enable
    output  logic   [WIDTH-1:0] rd_data,    // Current first FIFO word
    output  logic               full,       // Full flag
    output  logic               empty       // Empty flag
);

    // DEPTH constraint: DEPTH > 2 and DEPTH power of 2
    generate
        if ((DEPTH < 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial begin
                $fatal(1, "Error: DEPTH must be > 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
            end
        end
    endgenerate

    localparam int PTR_WIDTH  = $clog2(DEPTH);
    localparam int ADDR_WIDTH = PTR_WIDTH-1;

    logic [  WIDTH-1:0] mem [DEPTH];    // FIFO internal memory
    logic [PTR_WIDTH:0] wr_ptr, rd_ptr; // Pointers
    logic [PTR_WIDTH:0] ptr_cnt;        //Occupancy

    always_ff @(posedge clk or negedge rstn) begin : pointer_advance
        if (!rstn) begin
            wr_ptr  <= '0;
            rd_ptr  <= '0;
            ptr_cnt <= '0;
            empty   <= 1;
        end else begin
            case ({rd_en, wr_en})
                2'b00: ;    // do nothing

                2'b01: begin
                    if (!ptr_cnt[PTR_WIDTH]) begin  // !full
                        mem[wr_ptr[ADDR_WIDTH:0]] <= wr_data;
                        wr_ptr                    <= wr_ptr + 1;
                        ptr_cnt                   <= ptr_cnt + 1;
                        empty                     <= 0;
                    end
                end

                2'b10: begin
                    if (ptr_cnt != '0) begin    // !empty
                        rd_ptr  <= rd_ptr + 1;
                        ptr_cnt <= ptr_cnt - 1;
                    end

                    if (ptr_cnt <= 1)
                        empty <= 1;
                    else
                        empty <= 0;
                end

                2'b11: begin        // Lookup: *read write*
                    mem[wr_ptr[ADDR_WIDTH:0]] <= wr_data;

                    if ((ptr_cnt == '0)) begin
                        // FIFO was empty:
                        // accept the write, but don't consume the new word
                        ptr_cnt <= ptr_cnt + 1;
                        wr_ptr <= wr_ptr + 1;
                        empty  <= 0;
                    end else begin
                        // FIFO was non-empty:
                        // consume one word and add one word
                        wr_ptr <= wr_ptr + 1;
                        rd_ptr <= rd_ptr + 1;
                        empty  <= 0;
                    end
                end

                default: empty <= 0;
            endcase
        end
    end

    // Lookup: *output*
    assign rd_data = empty ? mem[rd_ptr[ADDR_WIDTH:0]-1'b1] : mem[rd_ptr[ADDR_WIDTH:0]];

    // Lookup: *full*
    assign full     = ((wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
                        wr_ptr[ADDR_WIDTH:0] == rd_ptr[ADDR_WIDTH:0]);

endmodule
