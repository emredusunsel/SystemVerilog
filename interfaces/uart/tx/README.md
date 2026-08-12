# UART Transmitter

## Overview

A parameterized **UART transmitter** that sends 8-bit data serially using a configurable clock frequency and baud rate.

The transmitter creates a standard UART frame with one start bit, 8 data bits, and one stop bit. It provides `tx_busy` while transmission is in progress and generates a `tx_done` pulse when the transmission is complete.

## Features

- Configurable clock frequency
- Configurable baud rate
- 8-bit data transmission
- 1 start bit
- 1 stop bit
- LSB-first transmission
- `tx_busy` status signal
- `tx_done` completion pulse
- FSM-based control
- Fully synthesizable

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `CLK_FREQ` | 50 MHz | System clock frequency |
| `BAUD_RATE` | 115200 | UART baud rate |

The baud divider is calculated as:

    BAUD_DIV = CLK_FREQ / BAUD_RATE

## Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | System clock |
| `rstn` | Input | 1 | Active-low asynchronous reset |
| `data_in` | Input | 8 | Data byte to transmit |
| `tx_start` | Input | 1 | Starts a transmission |
| `tx` | Output | 1 | UART serial output |
| `tx_busy` | Output | 1 | High while transmission is active |
| `tx_done` | Output | 1 | High when transmission is complete |

## UART Frame

The transmitter sends the following frame:

    Start    Data Bits (LSB first)    Stop
      0       D0 D1 D2 D3 D4 D5 D6 D7   1

For example, if:

    data_in = 8'b10110010

the transmitted data bits are:

    D0 D1 D2 D3 D4 D5 D6 D7
     0  1  0  0  1  1  0  1

The complete frame is therefore:

    0 0 1 0 0 1 1 0 1 1
    ^                 ^
    Start             Stop

## Functionality

### Starting a Transmission

When `tx_start` is asserted while the transmitter is in `IDLE`, the input byte is loaded into the shift register together with the start and stop bits.

The frame is stored as:

    {STOP, DATA, START}

or:

    {1'b1, data_in, 1'b0}

The least significant bit is transmitted first.

### Serial Transmission

During the `SHIFT` state, `tx` is driven by the least significant bit of `tx_shift_reg`:

    tx = tx_shift_reg[0]

After each complete baud period, the shift register moves to the next bit:

    tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}

The transmitter therefore sends:

    START -> D0 -> D1 -> D2 -> D3 -> D4 -> D5 -> D6 -> D7 -> STOP

### Busy Signal

`tx_busy` is asserted while the transmitter is in the `SHIFT` state.

    tx_busy = 1

This indicates that a transmission is currently in progress.

### Done Signal

After all 10 bits have been transmitted, the FSM enters the `DONE` state.

During this state:

    tx_done = 1

`tx_done` is asserted for one clock cycle before the transmitter returns to `IDLE`.

## FSM

The transmitter uses three states:

| State | Description |
|---|---|
| `IDLE` | Waiting for `tx_start` |
| `SHIFT` | Transmitting the UART frame |
| `DONE` | Indicates transmission completion |

State flow:

    IDLE -> SHIFT -> DONE -> IDLE

## Timing

Each UART bit is held on `tx` for approximately:

    BAUD_DIV = CLK_FREQ / BAUD_RATE

clock cycles.

For the default configuration:

    CLK_FREQ  = 50 MHz
    BAUD_RATE = 115200

Therefore:

    BAUD_DIV ≈ 434

Each transmitted bit remains on the output for approximately 434 clock cycles.

## Example

    logic       clk;
    logic       rstn;
    logic [7:0] data_in;
    logic       tx_start;
    logic       tx;
    logic       tx_busy;
    logic       tx_done;

    uart_tx #(
        .CLK_FREQ  (50_000_000),
        .BAUD_RATE (115_200)
    ) dut (
        .clk      (clk),
        .rstn     (rstn),
        .data_in  (data_in),
        .tx_start (tx_start),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );

To transmit a byte:

    data_in  = 8'hA5;
    tx_start = 1;

After `tx_start` is accepted:

    tx_busy = 1

When the complete frame has been transmitted:

    tx_busy = 0
    tx_done = 1

## Notes

- The UART frame uses 8 data bits, no parity, and 1 stop bit.
- Data is transmitted LSB first.
- The `tx` line is idle-high.
- `tx_busy` remains high for the duration of the transmission.
- `tx_done` is asserted for one clock cycle after the final stop bit.
- `tx_start` should be asserted to initiate a new transmission.
- The baud divider uses integer division, so the actual baud rate may have a small error depending on `CLK_FREQ` and `BAUD_RATE`.