
module uart_tx #(
    parameter int CLK_FREQ = 50_000_000,
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
        SHIFT,
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
                    next_state = SHIFT;
                else
                    next_state = IDLE;
            end

            SHIFT: begin
                if ((bit_counter == 4'd9) && (baud_counter == BAUD_DIV - 1))
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
            tx_shift_reg    <= '1;
        end else begin
            case (state)
                IDLE: begin
                    if (tx_start)
                        tx_shift_reg <= {1'b1, data_in, 1'b0};
                end

                SHIFT: begin
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
        tx_busy = 0;
        tx_done = 0;
        case (state)
            IDLE: begin
                tx_busy = 0;
                tx_done = 0;
            end

            SHIFT: begin
                tx_busy = 1;
            end

            DONE: begin
                tx_busy = 0;
                tx_done = 1;
            end

            default: ;
        endcase
    end

    assign tx = (state == SHIFT) ? tx_shift_reg[0] : 1'b1;

endmodule
