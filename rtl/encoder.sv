// Encoder

module encoder #(
    parameter int WIDTH = 8
) (
    input   logic [        WIDTH-1:0] data_i,
    output  logic [$clog2(WIDTH)-1:0] encoded_o,
    output  logic                     valid_o
);

    localparam int ENC_WIDTH = $clog2(WIDTH);

    logic first_flag;

    always_comb begin : encode
        encoded_o  = '0;
        valid_o    = 0;
        first_flag = 0;

        for (int i = WIDTH-1; i>=0; i--) begin
            if (!first_flag) begin
                if (data_i[i] == 1'b1) begin
                    encoded_o  = ENC_WIDTH'(i);
                    valid_o    = 1;
                    first_flag = 1;
                end
            end
        end
    end

endmodule