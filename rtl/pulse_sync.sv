// Pulse Synchronizer

module pulse_sync (
    input  logic clk_src_i,
    input  logic clk_dst_i,
    input  logic rstn_i,
    input  logic pulse_src_i,
    output logic pulse_dst_o
);

    logic toggle_src;

    logic sync_ff1;
    logic sync_ff2;
    logic toggle_dst_d;

    // Source clock domain
    always_ff @(posedge clk_src_i or negedge rstn_i) begin
        if (!rstn_i) begin
            toggle_src <= 1'b0;
        end else if (pulse_src_i) begin
            toggle_src <= ~toggle_src;
        end
    end

    // Destination clock domain
    always_ff @(posedge clk_dst_i or negedge rstn_i) begin
        if (!rstn_i) begin
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
    assign pulse_dst_o = sync_ff2 ^ toggle_dst_d;

endmodule
