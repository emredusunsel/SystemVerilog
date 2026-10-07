// UART top module

//                 +----------------+
// tx_data -------> |                |
// tx_start ------> |    uart_tx     | -------> tx = rx
//                 |                |
//                 +----------------+
//                     |
//                     +---- tx_busy
//                     |
//                     +---- tx_done

//                 +----------------+
// rx ------------> |                |
//                 |    uart_rx     | -------> rx_data
//                 |                |
//                 +----------------+
//                     |
//                     +---- rx_valid

// UART lookback should be done in the testbench file:
//      assign rx = tx;


module uart #(
    parameter int CLK_FREQ = 50_000_000,    // System clock frequency
    parameter int BAUD_RATE = 115_200       // UART baud rate
) (
    input   logic           clk,
    input   logic           rstn,
    // TX signals
    input   logic   [7:0]   tx_data,    // Data byte to transmit
    input   logic           tx_start,   // Starts a transmission
    output  logic           tx,         // UART serial transmit line
    output  logic           tx_busy,    // HIGH while transmission is active
    output  logic           tx_done,    // HIGH when transmission is complete
    // RX signals
    input   logic           rx,         // UART serial receive line
    output  logic   [7:0]   rx_data,    // Received data byte
    output  logic           rx_valid    // HIGH when a byte has been received
);
    
    // Instantiate: UART Transmitter
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

    // Instantiate: UART Recevier
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