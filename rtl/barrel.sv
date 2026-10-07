// Barrel Shifter

// *generate*
    // stage array generated with the depth of $clog2(WIDTH).
    // Initial stage (stage[0]) rotates the data by 1 if shamt_i[0] is 1, else it gets the raw data value.
    // Next stages (stage[i]) rotates the data stored by the previous stage (stage[i-1]) by 2^i amount
    //  if the corresponding shamt bit (shamt_i[i]) is 1, else it gets the valure of previous stage.
    // Generate for block's i initial value is 1, since stage[0] is already defined.
    // Result is assigned to the last stage (stage[$clog2(WIDTH-1)]);

module barrel #(
    parameter int WIDTH = 8
) (
    input  logic [        WIDTH-1:0] data_i,   // Input data
    input  logic [$clog2(WIDTH)-1:0] shamt_i,  // Number of positions to rotate right
    output logic [        WIDTH-1:0] result_o  // Rotated output
);

    // Stage 0 -> rotate by 1
    // Stage 1 -> rotate by 2
    // Stage 2 -> rotate by 4
    // ...
    logic [WIDTH-1:0] stage [0:$clog2(WIDTH)-1];

    // Lookup: *generate*
    generate
        assign stage[0] = shamt_i[0] ? {data_i[0], data_i[WIDTH-1:1]} : data_i;
        for (genvar i = 1; i < $clog2(WIDTH); i++) begin
            assign stage[i] = shamt_i[i] ? {stage[i-1][(2**i-1):0], stage[i-1][WIDTH-1:2**i]} :
                                            stage[i-1];
        end
    endgenerate

    assign result_o = stage[$clog2(WIDTH)-1]; // Last stage value

endmodule
