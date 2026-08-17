
module lifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 16
) (
    input   logic                    clk,
    input   logic                    rstn,
    input   logic                    push,
    input   logic [       WIDTH-1:0] push_data,
    input   logic                    pop,
    output  logic [       WIDTH-1:0] pop_data,
    output  logic                    empty,
    output  logic                    full,
    output  logic [ $clog2(DEPTH):0] count
);

    // WIDTH constraint
    generate
        if ((WIDTH < 1)) begin
            initial
                $fatal(1, "Error: WIDTH must be >= 1. Current WIDTH = %0d",
                    WIDTH);
        end
    endgenerate

    // DEPTH constraint
    generate
        if ((DEPTH < 2) || ((DEPTH & (DEPTH - 1)) != 0)) begin
            initial
                $fatal(1, "Error: DEPTH must be > 2 and a power of two. Current DEPTH = %0d",
                    DEPTH);
        end
    endgenerate

    localparam int PTR_WIDTH = $clog2(DEPTH) + 1;

    logic [    WIDTH-1:0] mem [DEPTH];
    logic [PTR_WIDTH-1:0] stack_ptr;

    always_ff @(posedge clk) begin : lifo_block
        if (!rstn) begin
            stack_ptr <= '0;
            pop_data  <= '0;
        end else begin
            case ({pop, push})
                2'b00: ;            // do nothing

                2'b01: begin        // push
                    if (!full) begin
                        mem[stack_ptr] <= push_data;
                        stack_ptr      <= stack_ptr + 1;
                    end
                end

                2'b10: begin        // pop
                    if (!empty) begin
                        mem[stack_ptr] <= '0;       // OR 'x
                        stack_ptr      <= stack_ptr - 1;
                        pop_data       <= mem[stack_ptr - 1'b1];
                    end
                end

                2'b11: begin        // simultaneous push/pop
                    if (!empty && !full) begin
                        mem[stack_ptr - 1'b1] <= push_data;
                        pop_data              <= mem[stack_ptr - 1'b1];
                    end else if (empty) begin
                        mem[stack_ptr]  <= push_data;
                        stack_ptr       <= stack_ptr + 1;
                    end else if (full) begin
                        mem[stack_ptr - 1'b1] <= push_data;
                        pop_data              <= mem[stack_ptr - 1'b1];
                    end
                end

                default: ;
            endcase
        end
    end
    
    assign count = stack_ptr;
    assign full  = (stack_ptr == DEPTH);
    assign empty = (stack_ptr == '0);

endmodule
