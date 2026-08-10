
module encoder (
    input   logic   [7:0]   d,
    output  logic   [2:0]   y,
    output  logic           valid
);

    always_comb begin : encode
        y = '0;
        valid = 0;
        casez (d)
            8'b00000001: begin
                y = 3'd0;
                valid = 1;
            end
            8'b0000001?: begin
                y = 3'd1;
                valid = 1;
            end
            8'b000001??: begin
                y = 3'd2;
                valid = 1;
            end
            8'b00001???: begin
                y = 3'd3;
                valid = 1;
            end
            8'b0001????: begin
                y = 3'd4;
                valid = 1;
            end
            8'b001?????: begin
                y = 3'd5;
                valid = 1;
            end
            8'b01??????: begin
                y = 3'd6;
                valid = 1;
            end
            8'b1???????: begin
                y = 3'd7;
                valid = 1;
            end
            default: ;
        endcase
    end

endmodule
