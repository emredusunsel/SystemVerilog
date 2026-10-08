// Linear Feedback Shift Register (LFSR)

// SET FOR 4-bit POLYNOMAIAL. CHANGE ACCORDINGLY.

// Module advances the LFSR when enable is asserted and can load a new seed
//  through seed_valid. It also tracks the loaded seed so that it can detect
//  when the LFSR returns to its starting state.

// A new seed can be loaded by asserting seed_valid. The provided seed becomes
//  the current LFSR state and is also stored as the initial seed used for
//  sequence completion detection.
// A zero seed is not considered valid, causes the FSM to enter the LOCKED state.
// The LFSR advances when enable is asserted and the FSM is operation in a state
//  where advancement is allowed.
// When enable is not asserted, the current LFSR state is held.
// When clear is asserted, the LFSR and stored initial seed return to the default
//  INIT value. The FSM also returns to IDLE. The clear operation therefore
//  provides a complete restart of the LFSR sequence.

// IDLE state:
    // enable starts the sequence.
    // seed_valid loads a new seed.
    // clear returns the design to the initial state.
    // A zero seed causes LOCKED
// RUN state:
    // The LFSR is actively advancing. When enable is asserted, the next LFSR
    //  is calculated. The next state is checked for two special conditions,
    //  lfsr_next == 0 or lfsr_next == seed_init.
    // A zero next state causes LOCKED. Returning to the loaded seed causes DONE.
// DONE state:
    // The LFSR has returned to its loaded seed.
    // sequence_done is asserted while the FSM is in this state.
    // The design can return to RUN if enable is asserted.
// LOCKED state:
    // The LFSR has entered the invalid zero state.
    // The LFSR remains locked until either clear is asserted or a new non-zero
    //  seed is loaded.

//  Output Table:
// | State  | valid | locked | sequence_done | lfsr_data          |
// |--------|-------|--------|---------------|--------------------|
// | IDLE   | 1     | 0      | 0             | Current LFSR state |
// | RUN    | 1     | 0      | 0             | Current LFSR state |
// | DONE   | 1     | 0      | 1             | Current LFSR state |
// | LOCKED | 0     | 1      | 0             | 0                  |

module lfsr #(
    parameter int         WIDTH      = 4,           // Width of the LFSR
    parameter logic [3:0] POLYNOMIAL = 4'b1100      // Feedback polynomial mask
) (
    input   logic             clk_i,
    input   logic             rstn_i,
    input   logic             enable_i,       // Advances LFSR when asserted
    input   logic             seed_valid_i,   // Requests loading of a new seed
    input   logic [WIDTH-1:0] seed_i,         // Seed value to load
    input   logic             clear_i,        // Returns LFSR to initial
    output  logic [WIDTH-1:0] lfsr_data_o,    // Current LFSR state
    output  logic             valid_o,        // LFSR contains valid non-zero state
    output  logic             locked_o,       // LFSR entered invalid zero state
    output  logic             sequence_done_o // LFSR returned to its loaded seed
);

    localparam logic [3:0] INIT = {1'b1, (WIDTH-1)'(0)};    // Initial LFSR state

    logic [WIDTH-1:0] lfsr_next, lfsr_current;
    logic [WIDTH-1:0] seed_init;        // Initial loaded seed or INIT when reset or clear

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE,
        LOCKED
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk_i) begin : state_logic
        if (!rstn_i)
            state <= IDLE;
        else
            state <= next_state;            
    end

    always_comb begin : next_state_logic
        case (state)
            
            IDLE: begin
                if (!clear_i) begin           // Clear priority
                    if (seed_valid_i) begin   // Request load seed
                        if (seed_i != 0)
                            next_state = IDLE;
                        else
                            next_state = LOCKED;
                    end else begin
                        if (enable_i)         // Advance
                            next_state = RUN;
                        else
                            next_state = IDLE;
                    end
                end else
                    next_state = IDLE;
            end

            RUN: begin
                if (!clear_i) begin           // Clear priorty
                    if (seed_valid_i) begin   // Request load seed
                        if (seed_i != 0)
                            next_state = IDLE;
                        else 
                            next_state = LOCKED;
                    end else begin
                        if (enable_i) begin   // Advance
                            if (lfsr_next == '0)                // Next LFSR == 0 check
                                next_state = LOCKED;
                            else if (lfsr_next == seed_init)    // Check if sequence complete
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
                if (!clear_i) begin           // Clear priority
                    if (seed_valid_i) begin   // Request load seed
                        if (seed_i != 0)
                            next_state = IDLE;
                        else
                            next_state = LOCKED;
                    end else begin
                        if (enable_i)         // Advance
                            next_state = RUN;
                        else
                            next_state = IDLE;
                    end
                end else
                    next_state = IDLE;
            end

            LOCKED: begin
                if (!clear_i) begin           // Clear priortiy
                    if (seed_valid_i) begin   // Request load seed
                        if (seed_i != 0)      // Only non-zero seed load break locked
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
                sequence_done_o = 0;
                locked_o        = 0;
                valid_o         = 1;
                lfsr_data_o     = lfsr_current;
            end

            RUN: begin
                sequence_done_o = 0;
                locked_o        = 0;
                valid_o         = 1;
                lfsr_data_o     = lfsr_current;
            end

            DONE: begin
                sequence_done_o = 1;
                locked_o        = 0;
                valid_o         = 1;
                lfsr_data_o     = lfsr_current;
            end

            LOCKED: begin
                sequence_done_o = 0;
                locked_o        = 1;
                valid_o         = 0;
                lfsr_data_o     = '0;
            end

            default: ;
        endcase
    end

    // Next LFSR calculated combinationally but current LFSR assigned sequentially
    //  based on conditions.
    always_ff @(posedge clk_i) begin : lfsr_current_block
        if (!rstn_i || clear_i)
            lfsr_current <= INIT;   // Initialize LFSR state
        else begin
            if ((state == IDLE) && seed_valid_i)  // Current state IDLE and new seed load ready
                lfsr_current <= seed_i;
            else if (next_state == RUN)         // Advance the LFSR
                lfsr_current <= lfsr_next;
            else if ((next_state == IDLE) && seed_valid_i)    // New seed load ready on next state
                lfsr_current <= seed_i;
            else if (next_state == DONE)        // Sequence will be done at next state
                lfsr_current <= lfsr_next;
            else
                lfsr_current <= lfsr_current;
        end 
    end

    always_ff @(posedge clk_i) begin : init_seed_block
        if (!rstn_i || clear_i)     // Reset clear priority
            seed_init <= INIT;
        else begin
            if (seed_valid_i)
                seed_init <= seed_i;
            else
                seed_init <= seed_init;
        end
    end

    // Next LFSR calculation based on current LFSR
    assign lfsr_next = {lfsr_current[WIDTH-2:0], ^(lfsr_current & POLYNOMIAL)};

endmodule
