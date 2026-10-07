// UART Transmitter

// Sends 8-bit data serially using a configurable clock frequency and baud rate.
// TX creates a standard UART frame with one start bit, 8 data bits, and one
//  stop bit. Provides tx_busy while transmission is in progress and generates
//  a tx_done pulse when the transmission is complete.
// LSB first transmission.
// Active-low asynchronous reset.
// No parity bit.

// The transmitter sends the following frame:
//     Start    Data Bits (LSB first)    Stop
//       0     D0 D1 D2 D3 D4 D5 D6 D7    1

// When tx_start is asserted while the transmitter is in IDLE, the input byte is
//  loaded into the shift register together with the start and stop bits.
// During the SHIFT state, tx is driven by the LSB of tx_shift_reg. After each
//  complete baud period, the shift register moves to the next bit.
// tx_busy is asserted while in the SHIFT state.
// After all 10 bits have been transmitted, the FSM enters the DONE state.
// tx_done is asserted for one clock cycle before transmitter returns to IDLE.

// *timing*
    // Each UART bit is held on tx for approximately BAUD_DIV clock cycles.

module uart_tx #(
    parameter int CLK_FREQ = 50_000_000,    // System clock frequency
    parameter int BAUD_RATE = 115_200       // UART baud rate
) (
    input   logic       clk_i,
    input   logic       rstn_i,
    input   logic [7:0] data_i,     // Data byte to transmit
    input   logic       tx_start_i, // Starts a transmission
    output  logic       tx_o,       // UART serial output
    output  logic       tx_busy_o,  // HIGH while transmission is active
    output  logic       tx_done_o   // HIGH when transmission is complete
);

    // Lookup: *timing*
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam int COUNTER_W = $clog2(BAUD_DIV);

    logic [COUNTER_W-1:0] baud_counter;
    logic [          3:0] bit_counter;
    logic [          9:0] tx_shift_reg;

    typedef enum logic [1:0] {
        IDLE,
        SHIFT,
        DONE
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk_i or negedge rstn_i) begin : state_logic
        if (!rstn_i)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : next_state_logic
        next_state = IDLE;

        case (state)
            IDLE: begin
                if (tx_start_i)
                    next_state = SHIFT;
                else
                    next_state = IDLE;
            end

            SHIFT: begin
                if ((bit_counter == 4'd9) && (baud_counter == COUNTER_W'(BAUD_DIV - 1)))
                    next_state = DONE;
                else
                    next_state = SHIFT;
            end

            DONE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin : datapath_seq_logic
        if (!rstn_i) begin
            baud_counter    <= '0;
            bit_counter     <= '0;
            tx_shift_reg    <= '1;  // tx line is IDLE-HIGH
        end else begin
            case (state)
                IDLE: begin
                    if (tx_start_i) // Load data_in if tx_start is asserted
                        tx_shift_reg <= {1'b1, data_i, 1'b0};
                end

                SHIFT: begin
                    // increment baud_counter until BAUD_DIV - 1
                    if (baud_counter == COUNTER_W'(BAUD_DIV - 1)) begin
                        baud_counter <= '0;

                        // increment bit counter when baud counter reaches BAUD_DIV - 1
                        if (bit_counter == 4'd9) begin
                            bit_counter     <= '0;
                        end else begin
                            bit_counter     <= bit_counter + 1;
                            tx_shift_reg    <= {1'b1, tx_shift_reg[9:1]};
                        end
                    end else
                        baud_counter <= baud_counter + 1'b1;
                end

                DONE: begin
                    baud_counter    <= '0;
                    bit_counter     <= '0;
                    tx_shift_reg    <= '1;  // tx line is IDLE-HIGH
                end

                default: ;
            endcase
        end
    end

    always_comb begin : output_logic
        tx_o      = 1;    // tx line is IDLE HIGH
        tx_busy_o = 0;
        tx_done_o = 0;
        case (state)
            IDLE: begin
                tx_o      = 1;
                tx_done_o = 0;
            end

            SHIFT: begin
                tx_o      = tx_shift_reg[0];
                tx_busy_o = 1;    // Transmission is in progress
            end

            DONE: begin
                tx_o      = 1;
                tx_busy_o = 0;
                tx_done_o = 1;    // Transmission is done
            end

            default: ;
        endcase
    end

endmodule
