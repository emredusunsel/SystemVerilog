
module pe_ne_det (
    input   logic   clk,
    input   logic   signal,
    output  logic   pe,
    output  logic   ne
);

    logic delayed_signal;

    always_ff @(posedge clk) begin : delay
            delayed_signal <= signal;        
    end

    assign pe = signal & ~delayed_signal;
    assign ne = ~signal & delayed_signal;

endmodule
