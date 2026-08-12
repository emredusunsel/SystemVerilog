
module register #(
    parameter int               WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0
) (
    input   logic               clk,
    input   logic               rstn,
    input   logic               en,
    input   logic   [WIDTH-1:0] in,
    output  logic   [WIDTH-1:0] out
);

    always_ff @(posedge clk or negedge rstn) begin : reg_ff
        if (!rstn)
            out <= RESET_VALUE;
        else if (en)
            out <= in;       
    end

endmodule
