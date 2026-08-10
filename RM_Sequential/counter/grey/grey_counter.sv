
module grey_counter #(
    parameter int WIDTH = 4
) (
    input   logic               clk,
    input   logic               rstn,
    output  logic   [WIDTH-1:0] q
);

    logic [WIDTH-1:0] bcd_count;
    initial bcd_count = '0;

    always_ff @(posedge clk or negedge rstn) begin : grey_code
        if (!rstn) begin
            bcd_count <= '0;
        end else begin
            bcd_count <= bcd_count + 1'b1;
        end
    end

    always_comb begin : bcd_to_grey
        for (int i = 0; i < WIDTH; i++) begin
            if (i < WIDTH-1)
                q[i] = bcd_count[i] ^ bcd_count[i+1];
            else
                q[WIDTH-1] = bcd_count[WIDTH-1]; 
        end
    end

endmodule
