// Pattern Detector

// Pattern: 110101

module pattern_detector (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic in_i,
    output logic out_o
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

    always_ff @(posedge clk_i or negedge rstn_i) begin : seq_block
        if (!rstn_i)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : comb_block
        next_state = IDLE;

        case (state)
            IDLE:       if (in_i)
                            next_state = S1;
                        else
                            next_state = IDLE;
            S1:         if (in_i)
                            next_state = S11;
                        else
                            next_state = IDLE;
            S11:        if (!in_i)
                            next_state = S110;
                        else
                            next_state = S1;
            S110:       if (in_i)
                            next_state = S1101;
                        else
                            next_state = IDLE;
            S1101:      if (!in_i)
                            next_state = S11010;
                        else
                            next_state = S11;
            S11010:     if (in_i)
                            next_state = S110101;
                        else
                            next_state = IDLE;
            S110101:    if (in_i)
                            next_state = S11;
                        else
                            next_state = IDLE; 
            default: next_state = IDLE;
        endcase
    end

    assign out_o = (state == S110101) ? 1 : 0;

endmodule
