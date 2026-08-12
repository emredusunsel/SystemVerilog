# UART Receiver

## Overview

A parameterized **UART receiver** that receives 8-bit serial data using a configurable clock frequency and baud rate.

The receiver synchronizes the asynchronous `rx` input, detects the start bit, receives the 8 data bits, checks the stop bit, and asserts `rx_valid` when a complete byte has been received.

## Features

- Configurable clock frequency
- Configurable baud rate
- 8-bit UART data
- 1 start bit
- 1 stop bit
- LSB-first data reception
- 2-flip-flop input synchronizer
- Mid-bit sampling
- FSM-based control
- Receive-valid indication

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `CLK_FREQ` | 50 MHz | System clock frequency |
| `BAUD_RATE` | 115200 | UART baud rate |

The baud counter is calculated as:

    BAUD_DIV = CLK_FREQ / BAUD_RATE

## Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | System clock |
| `rstn` | Input | 1 | Active-low asynchronous reset |
| `rx` | Input | 1 | UART serial input |
| `data_out` | Output | 8 | Received byte |
| `rx_valid` | Output | 1 | High when a byte is successfully received |

## UART Frame

The receiver expects an 8-bit UART frame with one start bit and one stop bit:

    Start    Data Bits (LSB first)    Stop
      0       D0 D1 D2 D3 D4 D5 D6 D7   1

## Functionality

### Input Synchronization

The asynchronous `rx` input passes through two flip-flops:

    rx -> rx_sync1 -> rx_sync2

This provides basic protection against metastability.

### Start Bit Detection

In the `IDLE` state, the receiver waits for `rx_sync2` to go low.

After detecting the start bit, the receiver waits approximately half of a bit period before sampling:

    Half bit period = BAUD_DIV / 2

This places the sample near the center of the start bit.

### Data Reception

After detecting the start bit, the FSM enters the `SHIFT` state.

Each data bit is sampled once per baud period and stored in `rx_shift_reg`.

    rx_shift_reg[bit_counter] <= rx_sync2;

The first received bit is stored in bit `0`, matching the LSB-first UART format.

### Stop Bit

After receiving all 8 data bits, the receiver waits for the stop bit.

The stop bit is expected to be high:

    rx_sync2 = 1

The receiver samples it approximately in the middle of the bit period.

### Receive Valid

After a valid stop bit is detected:

    rx_valid = 1

The received byte is available through:

    data_out

The receiver then returns to the `IDLE` state.

## FSM

The receiver uses three states:

| State | Description |
|---|---|
| `IDLE` | Waits for the start bit |
| `SHIFT` | Receives the 8 data bits and stop bit |
| `DONE` | Completes the reception |

State flow:

    IDLE -> SHIFT -> DONE -> IDLE

## Example

    logic       clk;
    logic       rstn;
    logic       rx;
    logic [7:0] data_out;
    logic       rx_valid;

    uart_rx #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (115_200)
    ) dut (
        .clk      (clk),
        .rstn     (rstn),
        .rx       (rx),
        .data_out (data_out),
        .rx_valid (rx_valid)
    );

For example, after receiving `8'hA5`:

    data_out = 8'hA5
    rx_valid = 1

## Notes

- The receiver uses an 8-bit data frame with no parity and one stop bit.
- The `rx` input is synchronized using two flip-flops.
- Data is sampled near the center of each UART bit.
- `rx_valid` indicates that a complete byte has been received.
- The `sample` signal is only used for timing and debugging purposes.
- The baud divider uses integer division, so the actual baud rate may have a small error depending on `CLK_FREQ` and `BAUD_RATE`.