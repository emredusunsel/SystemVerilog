
module encoder #(
    parameter int WIDTH     = 8,
    parameter int Y_WIDTH   = $clog2(WIDTH)
) (
    input   logic   [  WIDTH-1:0]   d,
    output  logic   [Y_WIDTH-1:0]   y,
    output  logic                   valid
);

    always_comb begin : encode
        y = '0;
        valid = 0;
        for (int i = 0; i < WIDTH; i++) begin
            if (d[i]) begin
                y = i;
                valid = 1;
            end
        end
    end

endmodule
