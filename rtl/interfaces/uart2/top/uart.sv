
module uart #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 115_200
) (
    input   logic           clk,
    input   logic           rstn,
    // TX
    input   logic   [7:0]   tx_data,
    input   logic           tx_start,
    output  logic           tx,
    output  logic           tx_busy,
    output  logic           tx_done,
    // RX
    input   logic           rx,
    output  logic   [7:0]   rx_data,
    output  logic           rx_valid
);
    
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk        (clk),
        .rstn       (rstn),
        .data_in    (tx_data),
        .tx_start   (tx_start),
        .tx         (tx),
        .tx_busy    (tx_busy),
        .tx_done    (tx_done)
    );

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk        (clk),
        .rstn       (rstn),
        .rx         (rx),
        .data_out   (rx_data),
        .rx_valid   (rx_valid)
    );

endmodule