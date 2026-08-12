
module uart_rx #(
    parameter int CLK_FREQ  = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input   logic           clk,
    input   logic           rstn,
    input   logic           rx,
    output  logic   [7:0]   data_out,
    output  logic           rx_valid
);
    
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

    logic [$clog2(BAUD_DIV)-1:0] baud_counter;
    logic [                 3:0] bit_counter;
    logic [                 7:0] rx_shift_reg;

    logic rx_sync1, rx_sync2;
    logic stop_flag;

    logic sample;       // unnecessary, only for checking the timing purposes

    typedef enum logic [1:0] {
        IDLE,
        SHIFT,
        DONE
    } state_t;

    state_t state, next_state;

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
                    if (!rx_sync2) begin
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
                        if (baud_counter == (BAUD_DIV - 1)) begin
                            baud_counter                <= '0;
                            bit_counter                 <= bit_counter + 1;
                            rx_shift_reg[bit_counter]   <= rx_sync2;
                            sample <= 1;
                        end else begin
                            baud_counter <= baud_counter + 1;
                            sample <= 0;
                        end
                    end else if ((bit_counter == 4'd8) && (rx_sync2 == 1)) begin
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
