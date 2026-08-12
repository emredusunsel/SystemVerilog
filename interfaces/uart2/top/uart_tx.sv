
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

    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        DONE
    } state_t;

    state_t state, next_state;

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
                if (tx_start)
                    next_state = BUSY;
                else
                    next_state = IDLE;
            end

            BUSY: begin
                if ((baud_counter == BAUD_DIV - 1) &&
                    (bit_counter == 4'd9))
                    next_state = DONE;
                else
                    next_state = BUSY;
            end

            DONE:   next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk or negedge rstn) begin : datapath_seq_logic
        if (!rstn) begin
            baud_counter    <= '0;
            bit_counter     <= '0;
            tx_shift_reg    <= '1;
        end else begin
            case (state)
                IDLE: begin
                    baud_counter    <= '0;
                    bit_counter     <= '0;
                    if (tx_start)
                        tx_shift_reg <= {1'b1, data_in, 1'b0};
                end

                BUSY: begin
                    if (baud_counter == BAUD_DIV - 1) begin
                        baud_counter <= '0;

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
                    tx_shift_reg    <= '1;
                end

                default: ;
            endcase
        end
    end

    always_comb begin : output_logic
        tx      = 1;
        tx_busy = 0;
        tx_done = 0;

        case (state)
            IDLE: begin
                tx      = 1;
            end

            BUSY: begin
                tx_busy = 1;
                if (bit_counter == 4'd9)
                    tx      = 1;
                else
                    tx      = tx_shift_reg[0];
            end

            DONE: begin
                tx      = 1;
                tx_done = 1;
            end
            default: tx = 1;
        endcase
    end

endmodule
