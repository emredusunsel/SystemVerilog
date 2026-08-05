
module mux(
    input   logic           a,
    input   logic           b,
    input   logic           c,
    input   logic           d,
    input   logic   [1:0]   sel,
    output  logic           y
);

    assign y = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a); 

endmodule
