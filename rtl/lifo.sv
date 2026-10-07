// Last-In, First-Out

// The most recently pushed data is the first data returned by a pop operaiton.
// Pointer tracks the next available stack location.
// Pop clears the contents of mem[stack_ptr - 1].
// Synchronous reset. Mem contents are not reset.

// | pop | push | Condition           | Operation                         |
// |-----|------|---------------------|-----------------------------------|
// | 0   | 0    | Any                 | No operation                      |
// | 0   | 1    | full_o = 0          | Push                              |
// | 0   | 1    | full_o = 1          | No operation                      |
// | 1   | 0    | empty_o = 0         | Pop                               |
// | 1   | 0    | empty_o = 1         | No operation                      |
// | 1   | 1    | Non-empty, non-full | Pop top and replace with new data |
// | 1   | 1    | Empty               | Push new data                     |
// | 1   | 1    | Full                | Pop top and replace with new data |

// *push pop*
    // While both push_i and pop_i is asserted, if;
    //      Non-Empty, Non-Full:
    //              Current top element is outputted, while
    //               push_data_i replaces it.
    //      Empty:
    //              Push is accepted, pointer incremented.
    //              New element is stored in the stack.
    //      Full:
    //              Top element is outputted and replaced by
    //               push_data_i.
    //              Stack remains full.

module lifo #(
    parameter int WIDTH = 8,    // Number of bits per stack element
    parameter int DEPTH = 16    // Maximum number of elements
) (
    input   logic                   clk_i,
    input   logic                   rstn_i,
    input   logic                   push_i,      // Push
    input   logic [      WIDTH-1:0] push_data_i, // Data to push
    input   logic                   pop_i,       // Pop
    output  logic [      WIDTH-1:0] pop_data_o,  // Popped data
    output  logic                   empty_o,     // Empty flag
    output  logic                   full_o,      // Full flag
    output  logic [$clog2(DEPTH):0] count_o      // Occupancy
);

    // WIDTH constraint: WIDTH >= 1
    generate
        if ((WIDTH < 1)) begin
            initial
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
        end
    endgenerate

    // DEPTH constraint: DEPTH >=2 and DEPTH power of 2
    generate
        if ((DEPTH < 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial
                $fatal(1, "Error: DEPTH must be >= 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
        end
    endgenerate

    // +1 bit for detection of flags
    localparam int PTR_WIDTH = $clog2(DEPTH) + 1;

    logic [    WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0] stack_ptr;    // Pointer

    always_ff @(posedge clk_i) begin : lifo_block
        if (!rstn_i) begin
            stack_ptr  <= '0;
            pop_data_o <= '0;
        end else begin
            case ({pop_i, push_i})
                2'b00: ;            // Do nothing

                2'b01: begin        // Push
                    if (!full_o) begin
                        mem[stack_ptr[PTR_WIDTH-2:0]] <= push_data_i;
                        stack_ptr                     <= stack_ptr + 1;
                    end
                end

                2'b10: begin        // Pop
                    if (!empty_o) begin
                        mem[stack_ptr[PTR_WIDTH-2:0] - 1'b1] <= '0;
                        stack_ptr                            <= stack_ptr - 1'b1;
                        pop_data_o                           <= mem[stack_ptr[PTR_WIDTH-2:0] - 1'b1];
                    end
                end

                2'b11: begin        // Lookup: *push pop*
                    if (empty_o) begin
                        mem[stack_ptr[PTR_WIDTH-2:0]] <= push_data_i;
                        stack_ptr                     <= stack_ptr + 1'b1;
                    end else begin
                        mem[stack_ptr[PTR_WIDTH-2:0] - 1'b1] <= push_data_i;
                        pop_data_o                           <= mem[stack_ptr[PTR_WIDTH-2:0] - 1'b1];
                    end
                end

                default: ;
            endcase
        end
    end
    
    assign count_o = stack_ptr;
    assign full_o  = (stack_ptr == PTR_WIDTH'(DEPTH));
    assign empty_o = (stack_ptr == '0);

endmodule
