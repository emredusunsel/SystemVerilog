
module occ #(
    parameter int DATA_WIDTH = 8,       // Input data width
    parameter int POLYNOMIAL = 8'h74    // CRC polynomial
) (
    input   logic                       clk,
    input   logic                       rstn,
    input   logic                       start,
    input   logic   [DATA_WIDTH-1:0]    data,
    output  logic   [DATA_WIDTH-1:0]    data_out,
    output  logic                       finish
);

    logic [DATA_WIDTH-1:0] crc_temp;
    logic feedback;
    logic [$clog2(DATA_WIDTH):0] counter;
 
    typedef enum logic [1:0] {
        IDLE,
        HOLD,
        RUN
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin : state_logic
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : next_state_logic
        case (state)
            IDLE: begin
                if (start)
                    next_state = RUN;
                else
                    next_state = IDLE;
            end

            HOLD: begin
                if (start)
                    next_state = RUN;
                else
                    next_state = HOLD;
            end

            RUN: begin
                if (finish)
                    next_state = HOLD;
                else
                    next_state = RUN;
            end
            default: next_state = next_state;
        endcase
    end

    always_ff @(posedge clk) begin : blockName
        if (state == IDLE) begin
            counter <= '0;
            crc_temp <= '0;
        end else if (state == HOLD) begin
            counter <= '0;
        end else if (state == RUN) begin
            if (counter < DATA_WIDTH) begin
                if (feedback)
                    crc_temp <= (crc_temp << 1) ^ POLYNOMIAL;
                else
                    crc_temp <= (crc_temp << 1);
                counter <= counter + 1;
            end
            if (next_state == HOLD || IDLE)
                counter <= '0;
        end
    end

    assign feedback = (crc_temp[DATA_WIDTH-1] ^ data[DATA_WIDTH-1-counter]);;
    assign finish = (counter == 8);
    assign data_out = (counter == 8) ? crc_temp : '0;

endmodule
