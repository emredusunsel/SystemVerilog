
module tff (
    input   logic   clk,
    input   logic   rstn,
    input   logic   t,
    output  logic   q
);

    always_ff @(posedge clk or negedge rstn) begin : t_flipflop
        if (!rstn)
            q <= '0;
        else begin
            if (t)
                q <= ~q;
            else
                q <= q;
        end
    end

endmodule
