// UART Receiver

// Receives 8-bit serial data using a configurable clock frequenct and baud rate.
// Synchronizes the asynchronous rx input, detects the start bit, receives the
//  8 data bits, checks the stop bit, and asserts rx_valid when a complete byte
//  has been received.
// LSB-first data reception.
// 2-flip-flop input synchronizer.
// Mid-bit sampling.
// No parity bit.

// The receiver expects an 8-bit UART frame with one start bit and one stop bit:
//     Start    Data Bits (LSB first)    Stop
//       0     D0 D1 D2 D3 D4 D5 D6 D7    1

// The asycnhronous rx input passes through two flip-flops.
// In the IDLE state, receiver waits for rx_sync2 to go low, since tx idle is HIGH.
// After detecting the start bit, the receiver waits approximately half of a bit
//  period before sampling(BUD_DIV / 2). This places the sample near the center
//  of the start bit.
// After detecting the start bit, the FSM enters the SHIFT state.
// Each bit is sampled once per baud period and stored in rx_shift_reg:
//      rx_shift_reg[bit_counter] <= rx_sync2;
// The first received bit is stored in bit 0, matching the LSB-first UART format.
// After receiving all 8 data bits, the receiver waits for the stop bit, which is
//  expected to be HIGH. The receiver samples it approximately in the middle of
//  the bit period.
// After a valid stop bit is detected rx_valid is asserted, the received byte is 
//  available through data_out. The receiver then returns to the IDLE state.


module uart_rx #(
    parameter int CLK_FREQ  = 50_000_000,   // System clock frequency
    parameter int BAUD_RATE = 115_200       // UART baud rate
) (
    input   logic           clk,
    input   logic           rstn,
    input   logic           rx,         // UART serial input
    output  logic   [7:0]   data_out,   // Received byte
    output  logic           rx_valid    // HIGH when a byte is successfully received
);
    
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    logic [$clog2(BAUD_DIV)-1:0] baud_counter;
    logic [                 3:0] bit_counter;
    logic [                 7:0] rx_shift_reg;

    logic rx_sync1, rx_sync2;   // Synchronizers
    logic stop_flag;            // Stop flag

    logic sample;       // Unnecessary, only for checking the timing purposes

    typedef enum logic [1:0] {
        IDLE,
        SHIFT,
        DONE
    } state_t;

    state_t state, next_state;

    // Synchronization of asynchronous rx input
    always_ff @(posedge clk or negedge rstn) begin : ffsync
        if (!rstn) begin
            rx_sync1 <= 1;
            rx_sync2 <= 1;
        end else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always_ff @(posedge clk or negedge rstn) begin : state_logic
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : next_state_logic
        next_state = IDLE;

        case (state)
            IDLE: begin
                // Detect start bit
                if (!rx_sync2 && (baud_counter == ((BAUD_DIV / 2) - 1)))
                    next_state = SHIFT;
                else
                    next_state = IDLE;
            end

            SHIFT: begin
                if (stop_flag)
                    next_state = DONE;
                else
                    next_state = SHIFT;
            end

            DONE: next_state = IDLE;

            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rstn) begin : datapath_seq_logic
        if (!rstn) begin
            baud_counter    <= '0;
            bit_counter     <= '0;
            rx_shift_reg    <= '0;
            stop_flag       <= 0;
            sample          <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (!rx_sync2) begin    // Detect start bit
                        // Count half sample period to align the center of each UART bit
                        if (baud_counter == ((BAUD_DIV / 2) - 1)) begin
                            baud_counter    <= '0;
                            sample <= 1;
                        end else begin
                            baud_counter <= baud_counter + 1;
                            sample <= 0;
                        end
                    end
                end

                SHIFT: begin
                    if (bit_counter < 4'd8) begin
                        // Count full period since SHIFT state already started around center
                        if (baud_counter == (BAUD_DIV - 1)) begin
                            baud_counter                <= '0;
                            bit_counter                 <= bit_counter + 1;
                            rx_shift_reg[bit_counter]   <= rx_sync2;
                            sample <= 1;
                        end else begin
                            baud_counter <= baud_counter + 1;
                            sample <= 0;
                        end
                    // Detect stop bit
                    end else if ((bit_counter == 4'd8) && (rx_sync2 == 1)) begin
                        // Count half a period
                        if (baud_counter == ((BAUD_DIV / 2) - 1)) begin
                            baud_counter    <= '0;
                            stop_flag       <= 1;
                            bit_counter     <= '0;
                            sample  <= 1;
                        end else begin
                            baud_counter <= baud_counter + 1;
                            sample <= 0;
                        end
                    end else
                        sample <= 0;
                end

                DONE: begin
                    stop_flag       <= 0;
                end

                default: ;
            endcase
        end
    end

    assign data_out = rx_shift_reg;
    assign rx_valid = stop_flag;

endmodule
