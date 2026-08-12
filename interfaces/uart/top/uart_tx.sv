
// {1'b1(STOP BIT), data, 1'b0(START BIT)}
// Transmits from LSB to MSB

module uart_tx #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input   logic           clk,
    input   logic           rstn,
    input   logic   [7:0]   data_in,
    input   logic           tx_start,
    output  logic           tx,
    output  logic           tx_busy,
    output  logic           tx_done
);

    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    logic [$clog2(BAUD_DIV)-1:0] baud_counter;
    logic [                 3:0] bit_counter;
    logic [                 9:0] tx_shift_reg;

    always_ff @(posedge clk or negedge rstn) begin : tx_block
        if (!rstn) begin
            baud_counter    <= '0;
            bit_counter     <= '0;
            tx_shift_reg    <= '1;
            tx              <= 1'b1;
            tx_busy         <= 1'b0;
            tx_done         <= 1'b0;
        end else begin
            tx_done <= 1'b0;

            if (!tx_busy) begin
                if (tx_start) begin
                    tx_shift_reg    <= {1'b1, data_in, 1'b0};
                    tx              <= 1'b0;
                    tx_busy         <= 1'b1;
                    baud_counter    <= '0;
                    bit_counter     <= '0;
                end
            end else begin
                if (baud_counter == BAUD_DIV - 1) begin
                    baud_counter <= '0;

                    if (bit_counter == 4'd9) begin
                        tx              <= 1'b1;
                        tx_busy         <= 1'b0;
                        tx_done         <= 1'b1;
                        bit_counter     <= '0;
                        tx_shift_reg    <= '1;
                    end else begin
                        bit_counter     <= bit_counter + 1'b1;
                        tx_shift_reg    <= {1'b1, tx_shift_reg[9:1]};
                        tx              <= tx_shift_reg[1];
                    end
                end else begin
                    baud_counter <= baud_counter + 1'b1;
                end
            end
        end
    end 

endmodule
