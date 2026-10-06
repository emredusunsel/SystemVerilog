// Synchronized Edge Detector

// Two flip-flops provide basic synchronization for an asynchronous input.
// A change on signal is detected after passing through the synchronization
//  pipeline.

// *initial*
    // Module has no reset; The registers are initialized to 0 using
    //  an initial block.

// *logic*
    // previous value: delayed_signal || current value: sync2.
    // If previous value LOW and current value HIGH => positive edge.
    // If previous value HIGH and current value LOW => negative edge.

module sync_det (
    input   logic   clk,
    input   logic   signal, // Input signal
    output  logic   pe,     // Positive edge
    output  logic   ne      // Negative edge
);

    logic sync1, sync2, delayed_signal;

    // Lookup: *initial*
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

    // Lookup: *logic*
    assign pe = sync2 & ~delayed_signal;
    assign ne = ~sync2 & delayed_signal;

endmodule
