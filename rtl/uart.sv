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
    input   logic       clk_i,
    input   logic       rstn_i,
    // TX signals
    input   logic [7:0] tx_data_i,  // Data byte to transmit
    input   logic       tx_start_i, // Starts a transmission
    output  logic       tx_o,       // UART serial transmit line
    output  logic       tx_busy_o,  // HIGH while transmission is active
    output  logic       tx_done_o,  // HIGH when transmission is complete
    // RX signals
    input   logic       rx_i,       // UART serial receive line
    output  logic [7:0] rx_data_o,  // Received data byte
    output  logic       rx_valid_o  // HIGH when a byte has been received
);
    
    // Instantiate: UART Transmitter
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk_i      (clk_i),
        .rstn_i     (rstn_i),
        .data_i     (tx_data_i),
        .tx_start_i (tx_start_i),
        .tx_o       (tx_o),
        .tx_busy_o  (tx_busy_o),
        .tx_done_o  (tx_done_o)
    );

    // Instantiate: UART Recevier
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk_i      (clk_i),
        .rstn_i     (rstn_i),
        .rx_i       (rx_i),
        .data_o     (rx_data_o),
        .rx_valid_o (rx_valid_o)
    );

endmodule