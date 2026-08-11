
module arbiter #(
    parameter int WIDTH = 4
) (
    input   logic   [WIDTH-1:0] req,
    output  logic   [WIDTH-1:0] grant
);

    logic priority_flag;

    always_comb begin : request_grant
        grant           = '0;
        priority_flag   = 0;

        for (int i = WIDTH-1; i >= 0; i--) begin
            if (!priority_flag) begin
                if (req[i]) begin
                    grant[i]        = 1;
                    priority_flag   = 1;
                end
            end
        end
    end

endmodule
