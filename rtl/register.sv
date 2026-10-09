// Register

`timescale 1ps/1ps

module register #(
    parameter int               WIDTH = 8,
    parameter logic [WIDTH-1:0] RESET_VALUE = '0
) (
    input  logic             clk_i,
    input  logic             rstn_i,
    input  logic             en_i,
    input  logic [WIDTH-1:0] in_i,
    output logic [WIDTH-1:0] out_o
);

    always_ff @(posedge clk_i or negedge rstn_i) begin : reg_ff
        if (!rstn_i)
            out_o <= RESET_VALUE;
        else if (en_i)
            out_o <= in_i;       
    end

endmodule
