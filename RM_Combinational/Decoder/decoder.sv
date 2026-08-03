
module decoder (
    input   logic   [2:0]   addr,
    input   logic           en,
    output  logic   [7:0]   y
);

    assign y = en ? (8'b1 << addr) : '0;

endmodule
