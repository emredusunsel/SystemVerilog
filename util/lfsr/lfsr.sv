
module lfsr_temp #(
    parameter int WIDTH      = 4,
    parameter int POLYNOMIAL = 4'b1100     // width dependant
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               enable,         //advances lfsr when asserted
    input   logic               seed_valid,     //requests loading of a new seed
    input   logic   [WIDTH-1:0] seed,           //seed value to load
    input   logic               clear,          //returns lfsr to initial
    output  logic   [WIDTH-1:0] lfsr_data,      //current lfsr state
    output  logic               valid,          //lfsr contains valid non-zero state
    output  logic               locked,         //lfsr entered invalid zero state
    output  logic               sequence_done   //lfsr returned to its loaded seed
);

    localparam int INIT = {1'b1, (WIDTH-1)'(0)};

    logic [WIDTH-1:0] lfsr_next, lfsr_current;
    logic [WIDTH-1:0] seed_init;

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE,
        LOCKED
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
                if (!clear) begin
                    if (seed_valid) begin
                        if (seed != 0)
                            next_state = IDLE;
                        else
                            next_state = LOCKED;
                    end else begin
                        if (enable)
                            next_state = RUN;
                        else
                            next_state = IDLE;
                    end
                end else
                    next_state = IDLE;
            end

            RUN: begin
                if (!clear) begin
                    if (seed_valid) begin
                        if (seed != 0)
                            next_state = IDLE;
                        else 
                            next_state = LOCKED;
                    end else begin
                        if (enable) begin
                            if (lfsr_next == '0)
                                next_state = LOCKED;
                            else if (lfsr_next == seed_init)
                                next_state = DONE;
                            else
                                next_state = RUN;
                        end else
                            next_state = IDLE;
                    end
                end else 
                    next_state = IDLE;
            end

            DONE: begin
                if (!clear) begin
                    if (seed_valid) begin
                        if (seed != 0)
                            next_state = IDLE;
                        else
                            next_state = LOCKED;
                    end else begin
                        if (enable)
                            next_state = RUN;
                        else
                            next_state = IDLE;
                    end
                end else
                    next_state = IDLE;
            end

            LOCKED: begin
                if (!clear) begin
                    if (seed_valid) begin
                        if (seed != 0)
                            next_state = IDLE;
                        else
                            next_state = LOCKED;
                    end else
                        next_state = LOCKED;
                end else 
                    next_state = IDLE;
            end

            default: next_state = state; 
        endcase
    end

    always_comb begin : output_logic
        case (state)
            IDLE:  begin
                sequence_done = 0;
                locked = 0;
                valid = 1;
                lfsr_data = lfsr_current;
            end

            RUN: begin
                sequence_done = 0;
                locked = 0;
                valid = 1;
                lfsr_data = lfsr_current;
            end

            DONE: begin
                sequence_done = 1;
                locked = 0;
                valid = 1;
                lfsr_data = lfsr_current;
            end

            LOCKED: begin
                sequence_done = 0;
                locked = 1;
                valid = 0;
                lfsr_data = '0;
            end

            default: ;
        endcase
    end

    always_ff @(posedge clk) begin : lfsr_current_block
        if (!rstn || clear)
            lfsr_current <= INIT;
        else begin
            if ((state == IDLE) && seed_valid)
                lfsr_current <= seed;
            else if (next_state == RUN)
                lfsr_current <= lfsr_next;
            else if ((next_state == IDLE) && seed_valid)
                lfsr_current <= seed;
            else if (next_state == DONE)
                lfsr_current <= lfsr_next;
            else
                lfsr_current <= lfsr_current;
        end 
    end

    always_ff @(posedge clk) begin : init_seed_block
        if (!rstn || clear)
            seed_init <= INIT;
        else begin
            if (seed_valid)
                seed_init <= seed;
            else
                seed_init <= seed_init;
        end
    end

    assign lfsr_next = {lfsr_current[WIDTH-2:0], ^(lfsr_current & POLYNOMIAL)};

endmodule
