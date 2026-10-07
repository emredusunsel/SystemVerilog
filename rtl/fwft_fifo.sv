// First-Word Fall-Through FIFO

// The first stored word immediately available on rd_data_i without
//  requiring a read operation to load it.
// Active-low asynchronous reset.
// Read opeariton advances the read pointer and exposed the next FIFO word.
// Empty: No valid data available.
// Partially full: Data available for reading.
// Full: No additional writes accepted.
// wr_ptr points to the next write location.
// rd_ptr points to the current read location.
// rd_en_i means consume data.
// empty_o means all data are consumed.
// Simultaneous Read and Write supported.

// *read write*
    // While both rd_en_i and wr_en_i is asserted, if;
    //      Non-Empty FIFO:
    //          Existing word is consumed while the new word is added.
    //          Occupancy remains unchanged.
    //          Pointers increment.
    //      Empty FIFO:
    //          The new data is accepted, but the newly written word is
    //           not consumed by the same-cycle read request.
    //          Write is treated as the first valid FIFO entry.
    //          Empty turns LOW. empty_o -> 0
    //          Count increments. count -> 1
    //          Ensures that a read request cannot consume data that was not
    //           already available at the beginning of the cycle.
// *output*
    // rd_data_o = empty_o ? previous_read_location : current_read_location
    // When non-empty, rd_data_o directly reflects the memory location addressed
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
    // After the first succesful write into an empty FIFO, empty_o = 0,
    //  and the newly written word becomes available through rd_data_o.
    // Even though the word is immediately visible on the output, empty_o is not
    //  asserted until rd_en_o is asserted. rd_en_o means consume data, empty_o means
    //  all data are consumed.

`timescale 1ps/1ps
`include "../include/param_checks.svh"

module fwft_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16        // >= 2 and power of two
) (
    input   logic             clk_i,
    input   logic             rstn_i,
    input   logic             wr_en_i,   // Write enable
    input   logic [WIDTH-1:0] wr_data_i, // Data to be written
    input   logic             rd_en_i,   // Read enable
    output  logic [WIDTH-1:0] rd_data_o, // Current first FIFO word
    output  logic             full_o,    // Full flag
    output  logic             empty_o    // Empty flag
);

    // DEPTH constraint: DEPTH > 2 and DEPTH power of 2
    `CHECK_GREATER_THAN(DEPTH, 2)
    `CHECK_POWER_OF_TWO(DEPTH)

    localparam int PTR_WIDTH  = $clog2(DEPTH);
    localparam int ADDR_WIDTH = PTR_WIDTH-1;

    logic [  WIDTH-1:0] mem [0:DEPTH-1]; // FIFO internal memory
    logic [PTR_WIDTH:0] wr_ptr, rd_ptr;  // Pointers
    logic [PTR_WIDTH:0] ptr_cnt;         //Occupancy

    always_ff @(posedge clk_i or negedge rstn_i) begin : pointer_advance
        if (!rstn_i) begin
            wr_ptr  <= '0;
            rd_ptr  <= '0;
            ptr_cnt <= '0;
            empty_o <= 1;
        end else begin
            case ({rd_en_i, wr_en_i})
                2'b00: ;    // do nothing

                2'b01: begin
                    if (!ptr_cnt[PTR_WIDTH]) begin  // !full
                        mem[wr_ptr[ADDR_WIDTH:0]] <= wr_data_i;
                        wr_ptr                    <= wr_ptr + 1;
                        ptr_cnt                   <= ptr_cnt + 1;
                        empty_o                   <= 0;
                    end
                end

                2'b10: begin
                    if (ptr_cnt != '0) begin    // !empty
                        rd_ptr  <= rd_ptr + 1;
                        ptr_cnt <= ptr_cnt - 1;
                    end

                    if (ptr_cnt <= 1)
                        empty_o <= 1;
                    else
                        empty_o <= 0;
                end

                2'b11: begin        // Lookup: *read write*
                    mem[wr_ptr[ADDR_WIDTH:0]] <= wr_data_i;

                    if ((ptr_cnt == '0)) begin
                        // FIFO was empty:
                        // accept the write, but don't consume the new word
                        ptr_cnt <= ptr_cnt + 1;
                        wr_ptr  <= wr_ptr + 1;
                        empty_o <= 0;
                    end else begin
                        // FIFO was non-empty:
                        // consume one word and add one word
                        wr_ptr  <= wr_ptr + 1;
                        rd_ptr  <= rd_ptr + 1;
                        empty_o <= 0;
                    end
                end

                default: empty_o <= 0;
            endcase
        end
    end

    // Lookup: *output*
    assign rd_data_o = empty_o ? mem[rd_ptr[ADDR_WIDTH:0]-1'b1] : mem[rd_ptr[ADDR_WIDTH:0]];

    // Lookup: *full*
    assign full_o    = ((wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
                         wr_ptr[ADDR_WIDTH:0] == rd_ptr[ADDR_WIDTH:0]);

endmodule
