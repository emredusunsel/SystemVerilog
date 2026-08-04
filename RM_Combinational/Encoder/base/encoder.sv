
module encoder (
    input   logic   [7:0]   D,
    output  logic   [2:0]   Y,
    output  logic           valid
);

    always_comb begin : encode
        case (D)
            8'h01: begin
                Y = '0;
                valid = 1;
            end
            8'h02: begin
                Y = 3'd1;
                valid = 1;
            end
            8'h04: begin
                Y = 3'd2;
                valid = 1;
            end
            8'h08: begin
                Y = 3'd3;
                valid = 1;
            end
            8'h10: begin
                Y = 3'd4;
                valid = 1;
            end
            8'h20: begin
                Y = 3'd5;
                valid = 1;
            end
            8'h40: begin
                Y = 3'd6;
                valid = 1;
            end
            8'h80: begin
                Y = 3'd7;
                valid = 1;
            end
            default: begin
                Y = '0;
                valid = 0;
            end
        endcase
    end

endmodule
