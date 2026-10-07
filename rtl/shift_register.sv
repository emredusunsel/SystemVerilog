// Shift Register

module shift_register #(
    parameter int WIDTH = 8     // WIDTH >= 2
) (
    input  logic             clk_i,
    input  logic             rstn_i,
    input  logic             en_i,
    input  logic             serial_i,
    input  logic             dir_i,    // dir=0 shift right, dir=1 shift left
    output logic [WIDTH-1:0] q_o
);
    
    always_ff @(posedge clk_i or negedge rstn_i) begin : shift_reg_ff
        if (!rstn_i)
            q_o <= '0;
        else if (en_i)
            if (!dir_i)
                q_o <= {serial_i, q_o[WIDTH-1:1]};
            else
                q_o <= {q_o[WIDTH-2:0], serial_i};
    end

endmodule
