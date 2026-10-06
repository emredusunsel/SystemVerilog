
module encoder #(
    parameter int WIDTH = 8
) (
    input   logic   [        WIDTH-1:0] data,
    output  logic   [$clog2(WIDTH)-1:0] encoded,
    output  logic                       valid
);

    logic first_flag;

    always_comb begin : encode
        encoded     = '0;
        valid       = 0;
        first_flag  = 0;

        for (int i = WIDTH-1; i>=0; i--) begin
            if (!first_flag) begin
                if (data[i] == 1'b1) begin
                    encoded     = i;
                    valid       = 1;
                    first_flag  = 1;
                end
            end
        end
    end

endmodule