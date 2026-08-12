
// Pattern: 110101

module pattern_detector (
    input   logic   clk,
    input   logic   rstn,
    input   logic   in,
    output  logic   out
);
    
    typedef enum logic [2:0] {
        IDLE,
        S1,
        S11,
        S110,
        S1101,
        S11010,
        S110101
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
            IDLE:       if (in)
                            next_state = S1;
                        else
                            next_state = IDLE;
            S1:         if (in)
                            next_state = S11;
                        else
                            next_state = IDLE;
            S11:        if (!in)
                            next_state = S110;
                        else
                            next_state = S1;
            S110:       if (in)
                            next_state = S1101;
                        else
                            next_state = IDLE;
            S1101:      if (!in)
                            next_state = S11010;
                        else
                            next_state = S11;
            S11010:     if (in)
                            next_state = S110101;
                        else
                            next_state = IDLE;
            S110101:    if (in)
                            next_state = S11;
                        else
                            next_state = IDLE; 
            default: next_state = IDLE;
        endcase
    end

    assign out = (state == S110101) ? 1 : 0;

endmodule
