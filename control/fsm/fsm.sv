
module fsm (
    input   logic   clk,
    input   logic   rstn,
    input   logic   start,
    input   logic   done,
    input   logic   error,
    output  logic   busy,
    output  logic   valid,
    output  logic   fault
);

    typedef enum logic [1:0] {
        IDLE,
        BUSY,
        DONE,
        ERROR
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or negedge rstn) begin : seq_block
        if (!rstn)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin : comb_block
        next_state = IDLE;

        case (state)
            IDLE: begin
                if (start)
                    next_state = BUSY;
                else    
                    next_state = IDLE;
            end

            BUSY: begin
                if (error)
                    next_state = ERROR;
                else if (done)
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
        busy    = 0;
        valid   = 0;
        fault   = 0;
        
        case (state)
            BUSY: begin
                busy    = 1;
            end

            DONE: begin
                valid   = 1;
            end

            ERROR: begin
                fault   = 1; 
            end
            default: ;
        endcase
    end

endmodule
