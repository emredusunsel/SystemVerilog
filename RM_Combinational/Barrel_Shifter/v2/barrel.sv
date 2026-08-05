
module barrel (
    input   logic   [3:0]   data,
    input   logic   [1:0]   shamt,
    output  logic   [3:0]   result
);

    logic [6:0] filler;

    genvar i;

    generate
        for (i = 0; i < 4; i++) begin
            mux u_mux(
                .a(filler[i+3]),
                .b(filler[i+2]),
                .c(filler[i+1]),
                .d(filler[i]),
                .sel(shamt),
                .y(result[i])
            );
        end
    endgenerate

    assign filler[6:3] = data;
    assign filler[2:0] = 3'b000;

endmodule
