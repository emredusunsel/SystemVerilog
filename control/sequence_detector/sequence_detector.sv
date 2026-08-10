
module sequence_detector (
    input   logic   clk,
    input   logic   rstn,
    input   logic   in,
    output  logic   out
);

    typedef enum logic [2:0] {
        IDLE,
        S1,
        S10,
        S101,
        S1011
    } state_t;

    state_t state, next_state;

    initial state = IDLE;

    always_ff @(posedge clk or negedge rstn) begin : seq_block
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : comb_block
        next_state = IDLE;

        case (state)
            IDLE:   if (in)
                        next_state = S1;
                    else
                        next_state = IDLE;
            S1:     if (!in)
                        next_state = S10;
                    else
                        next_state = IDLE;
            S10:    if (in)
                        next_state = S101;
                    else
                        next_state = IDLE;
            S101:   if (in)
                        next_state = S1011;
                    else
                        next_state = IDLE;
            S1011:  next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    assign out = (state == S1011) ? 1 : 0;

endmodule
