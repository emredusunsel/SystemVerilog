
module ripple_counter #(
    parameter int WIDTH = 4
) (
    input   logic               clk,
    input   logic               rstn,
    output  logic   [WIDTH-1:0] q
);

    logic [WIDTH-1:0] q_out, qn_out;

    genvar i;

    generate
        for (i = 0; i < WIDTH; i++) begin
            if (i == 0) begin
                dff dff(
                    .clk(clk),
                    .rstn(rstn),
                    .d(qn_out[i]),
                    .q(q_out[i]),
                    .qn(qn_out[i])
                );   
            end else begin
                dff dff(
                    .clk(qn_out[i-1]),
                    .rstn(rstn),
                    .d(qn_out[i]),
                    .q(q_out[i]),
                    .qn(qn_out[i])
                );
            end
        end
    endgenerate

    assign q = q_out;

endmodule
