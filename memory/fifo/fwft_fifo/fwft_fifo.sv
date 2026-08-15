`timescale 1ps/1ps

module fwft_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16        // >= 2 and power of two
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               wr_en,
    input   logic   [WIDTH-1:0] wr_data,
    input   logic               rd_en,
    output  logic   [WIDTH-1:0] rd_data,
    output  logic               full,
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

    localparam int PTR_WIDTH    = $clog2(DEPTH);
    localparam int ADDR_WIDTH   = PTR_WIDTH-1;

    logic [  WIDTH-1:0] mem [DEPTH];
    logic [PTR_WIDTH:0] wr_ptr, rd_ptr, ptr_cnt;

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

                2'b11: begin        // SIMULTANEOUS READ/WRITE
                    mem[wr_ptr[ADDR_WIDTH:0]] <= wr_data;
                    wr_ptr                    <= wr_ptr + 1;
                    rd_ptr                    <= rd_ptr + 1;
                    empty                     <= 0;
                end

                default: empty <= 0;
            endcase
        end
    end

    // empty in always_ff was "flag"
    // empty was continuously assigned before
    // assign empty = flag ? (wr_ptr == rd_ptr) : 0;
    assign rd_data = empty ? mem[rd_ptr[ADDR_WIDTH:0]-1'b1] : mem[rd_ptr[ADDR_WIDTH:0]];
    
    assign full     = ((wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) &&
                        wr_ptr[ADDR_WIDTH:0] == rd_ptr[ADDR_WIDTH:0]);

endmodule
