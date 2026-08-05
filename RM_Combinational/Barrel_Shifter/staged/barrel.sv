
module barrel (
    input   logic   [7:0]   data,
    input   logic   [2:0]   shamt,
    output  logic   [7:0]   result
);

    logic   [7:0]   stage0;
    logic   [7:0]   stage1;

    assign stage0 = shamt[0] ? {data[0], data[7:1]} : data;
    assign stage1 = shamt[1] ? {stage0[1:0], stage0[7:2]} : stage0;
    assign result = shamt[2] ? {stage1[3:0], stage1[7:4]} : stage1;

endmodule
