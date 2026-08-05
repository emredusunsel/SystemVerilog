
module barrel (
    input   logic   [3:0]   data,
    input   logic   [1:0]   shamt,
    output  logic   [3:0]   result
);

    mux m0(
        .a(data[0]),
        .b(1'b0),
        .c(1'b0),
        .d(1'b0),
        .sel(shamt),
        .y(result[0])
    );

    mux m1(
        .a(data[1]),
        .b(data[0]),
        .c(1'b0),
        .d(1'b0),
        .sel(shamt),
        .y(result[1])
    );
    
    mux m2(
        .a(data[2]),
        .b(data[1]),
        .c(data[0]),
        .d(1'b0),
        .sel(shamt),
        .y(result[2])
    );
    
    mux m3(
        .a(data[3]),
        .b(data[2]),
        .c(data[1]),
        .d(data[0]),
        .sel(shamt),
        .y(result[3])
    );

endmodule
