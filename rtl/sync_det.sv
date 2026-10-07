// Synchronized Edge Detector

// Two flip-flops provide basic synchronization for an asynchronous input.
// A change on signal is detected after passing through the synchronization
//  pipeline.


// *logic*
    // previous value: delayed_signal || current value: sync2.
    // If previous value LOW and current value HIGH => positive edge.
    // If previous value HIGH and current value LOW => negative edge.

module sync_det (
    input  logic clk_i,
    input  logic rstn_i,
    input  logic signal_i, // Input signal
    output logic pe_o,     // Positive edge
    output logic ne_o      // Negative edge
);

    logic sync1, sync2, delayed_signal;

    always_ff @(posedge clk_i or negedge rstn_i) begin : sync
        if (!rstn_i) begin
            sync1          <= 0;
            sync2          <= 0;
            delayed_signal <= 0;
        end else begin
            sync1          <= signal_i;
            sync2          <= sync1;
            delayed_signal <= sync2;        
        end
    end

    // Lookup: *logic*
    assign pe_o = sync2 & ~delayed_signal;
    assign ne_o = ~sync2 & delayed_signal;

endmodule
