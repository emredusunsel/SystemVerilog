
module sync_det (
    input   logic   clk,
    input   logic   signal,
    output  logic   pe,
    output  logic   ne
);

    logic sync1, sync2, delayed_signal;

    initial begin
        sync1 = 0;
        sync2 = 0;
        delayed_signal = 0;
    end

    always_ff @(posedge clk) begin : sync
        sync1 <= signal;
        sync2 <= sync1;
        delayed_signal <= sync2;        
    end

    assign pe = sync2 & ~delayed_signal;
    assign ne = ~sync2 & delayed_signal;

endmodule
