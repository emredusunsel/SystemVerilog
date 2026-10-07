// Finite State Machine

module fsm (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic start_i,
    input  logic done_i,
    input  logic error_i,
    output logic busy_o,
    output logic valid_o,
    output logic fault_o
);

    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        DONE,
        ERROR
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
            IDLE: begin
                if (start_i)
                    next_state = BUSY;
                else    
                    next_state = IDLE;
            end

            BUSY: begin
                if (error_i)
                    next_state = ERROR;
                else if (done_i)
                    next_state = DONE;
                else
                    next_state = BUSY;
            end

            DONE: begin
                next_state = IDLE;
            end

            ERROR: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always_comb begin : output_logic
        busy_o  = 0;
        valid_o = 0;
        fault_o = 0;
        
        case (state)
            BUSY: begin
                busy_o  = 1;
            end

            DONE: begin
                valid_o = 1;
            end

            ERROR: begin
                fault_o = 1; 
            end
            default: ;
        endcase
    end

endmodule
