
module pulse_sync (
    input   logic   clk_src,
    input   logic   clk_dst,
    input   logic   rstn,
    input   logic   pulse_src,
    output  logic   pulse_dst
);

    logic toggle_src;

    logic sync_ff1;
    logic sync_ff2;
    logic toggle_dst_d;

    // Source clock domain
    always_ff @(posedge clk_src or negedge rstn) begin
        if (!rstn) begin
            toggle_src <= 1'b0;
        end else if (pulse_src) begin
            toggle_src <= ~toggle_src;
        end
    end

    // Destination clock domain
    always_ff @(posedge clk_dst or negedge rstn) begin
        if (!rstn) begin
            sync_ff1     <= 1'b0;
            sync_ff2     <= 1'b0;
            toggle_dst_d <= 1'b0;
        end else begin
            sync_ff1     <= toggle_src;
            sync_ff2     <= sync_ff1;
            toggle_dst_d <= sync_ff2;
        end
    end

    // Generate one destination-clock-cycle pulse
    assign pulse_dst = sync_ff2 ^ toggle_dst_d;

endmodule
