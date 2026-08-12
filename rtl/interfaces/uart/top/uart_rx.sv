module uart_rx #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input  logic       clk,
    input  logic       rstn,

    input  logic       rx,

    output logic [7:0] data_out,
    output logic       rx_valid
);

    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    logic [$clog2(BAUD_DIV)-1:0] baud_counter;
    logic [3:0]                  bit_counter;
    logic [7:0]                  rx_shift_reg;

    logic rx_sync1;
    logic rx_sync2;

    // 2FF synchronizer
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin : uart_rx_block
        if (!rstn) begin
            baud_counter <= '0;
            bit_counter  <= '0;
            rx_shift_reg <= '0;

            data_out     <= '0;
            rx_valid     <= 1'b0;
        end
        else begin
            rx_valid <= 1'b0;

            // --------------------------------
            // Wait for start bit
            // --------------------------------
            if (rx_sync2 == 1'b0 && bit_counter == 4'd0) begin

                // Wait half a baud period
                if (baud_counter == (BAUD_DIV / 2) - 1) begin
                    baud_counter <= '0;

                    // Confirm start bit
                    if (rx_sync2 == 1'b0) begin
                        bit_counter <= 4'd1;
                    end
                end
                else begin
                    baud_counter <= baud_counter + 1'b1;
                end

            end

            // --------------------------------
            // Receive data bits
            // --------------------------------
            else if (bit_counter >= 4'd1 &&
                     bit_counter <= 4'd8) begin

                if (baud_counter == BAUD_DIV - 1) begin
                    baud_counter <= '0;

                    rx_shift_reg[bit_counter - 1] <= rx_sync2;

                    bit_counter <= bit_counter + 1'b1;
                end
                else begin
                    baud_counter <= baud_counter + 1'b1;
                end

            end

            // --------------------------------
            // Stop bit
            // --------------------------------
            else if (bit_counter == 4'd9) begin

                if (baud_counter == BAUD_DIV - 1) begin
                    baud_counter <= '0;

                    if (rx_sync2 == 1'b1) begin
                        data_out <= rx_shift_reg;
                        rx_valid <= 1'b1;
                    end

                    bit_counter <= '0;
                end
                else begin
                    baud_counter <= baud_counter + 1'b1;
                end

            end

            // --------------------------------
            // Idle
            // --------------------------------
            else begin
                baud_counter <= '0;
                bit_counter  <= '0;
            end
        end
    end

endmodule
