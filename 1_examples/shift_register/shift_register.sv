
module shift_register #(
    parameter int WIDTH = 8     // WIDTH >= 2
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               en,
    input   logic               serial_in,
    input   logic               dir,    // dir=0 shift right, dir=1 shift left
    output  logic   [WIDTH-1:0] q
);
    
    always_ff @(posedge clk or negedge rstn) begin : shift_reg_ff
        if (!rstn)
            q <= '0;
        else if (en)
            if (!dir)
                q <= {serial_in, q[WIDTH-1:1]};
            else
                q <= {q[WIDTH-2:0], serial_in};
    end

endmodule
