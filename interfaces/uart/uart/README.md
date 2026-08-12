# UART

## Overview

A top-level **UART module** that combines the `uart_tx` and `uart_rx` modules into a single interface.

The module provides independent transmit and receive paths while sharing the same clock, reset, and UART configuration.

## Features

- Integrated UART transmitter and receiver
- Configurable clock frequency
- Configurable baud rate
- 8-bit TX and RX data
- LSB-first UART communication
- 1 start bit
- 1 stop bit
- TX busy and done status signals
- RX valid signal
- Separate TX and RX data paths

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `CLK_FREQ` | 50 MHz | System clock frequency |
| `BAUD_RATE` | 115200 | UART baud rate |

These parameters are passed to both the transmitter and receiver.

## Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | System clock |
| `rstn` | Input | 1 | Active-low asynchronous reset |
| `tx_data` | Input | 8 | Data byte to transmit |
| `tx_start` | Input | 1 | Starts a transmission |
| `tx` | Output | 1 | UART serial transmit line |
| `tx_busy` | Output | 1 | High while transmission is active |
| `tx_done` | Output | 1 | High when transmission is complete |
| `rx` | Input | 1 | UART serial receive line |
| `rx_data` | Output | 8 | Received data byte |
| `rx_valid` | Output | 1 | High when a byte has been received |

## Architecture

The top-level UART contains two independent modules:

```text
                 +----------------+
tx_data -------> |                |
tx_start ------> |    uart_tx     | -------> tx
                 |                |
                 +----------------+
                       |
                       +---- tx_busy
                       |
                       +---- tx_done


                 +----------------+
rx ------------> |                |
                 |    uart_rx     | -------> rx_data
                 |                |
                 +----------------+
                       |
                       +---- rx_valid
```

Both modules receive the same:

```text
clk
rstn
CLK_FREQ
BAUD_RATE
```

The transmitter and receiver otherwise operate independently.

## Transmit Path

The transmit path is handled by the `uart_tx` module.

The application provides:

```text
tx_data
tx_start
```

When `tx_start` is asserted, `uart_tx` loads `tx_data` and transmits the UART frame through `tx`.

The transmitter provides:

```text
tx_busy
tx_done
```

### TX Flow

```text
tx_data
   |
   v
tx_start
   |
   v
+---------+
| uart_tx |
+---------+
   |
   +------> tx
   |
   +------> tx_busy
   |
   +------> tx_done
```

`tx_busy` indicates that the transmitter is currently sending a byte.

`tx_done` indicates that the complete UART frame has been transmitted.

## Receive Path

The receive path is handled by the `uart_rx` module.

The external UART signal is connected to the `rx` input.

The receiver detects the start bit, samples the 8 data bits, checks the stop bit, and produces:

```text
rx_data
rx_valid
```

### RX Flow

```text
rx
 |
 v
+---------+
| uart_rx |
+---------+
   |
   +------> rx_data
   |
   +------> rx_valid
```

`rx_valid` indicates that a complete byte has been successfully received.

## UART Frame

Both transmitter and receiver use the same UART frame format:

```text
Start    Data Bits (LSB first)    Stop
  0       D0 D1 D2 D3 D4 D5 D6 D7   1
```

The default configuration is:

```text
Baud rate : 115200
Data      : 8 bits
Parity    : None
Stop      : 1 bit
```

This is commonly referred to as **8-N-1** UART.

## Module Integration

The transmitter instance:

```text
uart_tx
```

receives the top-level TX signals and parameters:

```text
tx_data
tx_start
CLK_FREQ
BAUD_RATE
```

and produces:

```text
tx
tx_busy
tx_done
```

The receiver instance:

```text
uart_rx
```

receives:

```text
rx
CLK_FREQ
BAUD_RATE
```

and produces:

```text
rx_data
rx_valid
```

The top-level module therefore acts primarily as a wrapper connecting the two modules together.

## Example

```text
logic       clk;
logic       rstn;

logic [7:0] tx_data;
logic       tx_start;
logic       tx;
logic       tx_busy;
logic       tx_done;

logic       rx;
logic [7:0] rx_data;
logic       rx_valid;

uart #(
    .CLK_FREQ  (50_000_000),
    .BAUD_RATE (115_200)
) dut (
    .clk      (clk),
    .rstn     (rstn),

    .tx_data  (tx_data),
    .tx_start (tx_start),
    .tx       (tx),
    .tx_busy  (tx_busy),
    .tx_done  (tx_done),

    .rx       (rx),
    .rx_data  (rx_data),
    .rx_valid (rx_valid)
);
```

### Transmission

To transmit a byte:

```text
tx_data  = 8'hA5
tx_start = 1
```

The `uart_tx` module transmits the byte through `tx`.

During transmission:

```text
tx_busy = 1
```

After the complete frame:

```text
tx_busy = 0
tx_done = 1
```

### Reception

When a UART frame arrives on `rx`, the `uart_rx` module receives it.

After a complete byte has been received:

```text
rx_data  = received_byte
rx_valid = 1
```

## Notes

- `uart` is a top-level wrapper around `uart_tx` and `uart_rx`.
- TX and RX can operate independently.
- The transmitter and receiver use the same `CLK_FREQ` and `BAUD_RATE` parameters.
- The `tx` and `rx` signals are the external UART serial interface.
- `tx_start` is used to begin transmission.
- `tx_busy` indicates an active transmission.
- `tx_done` indicates transmission completion.
- `rx_valid` indicates a newly received byte.
- The top-level module does not contain additional UART processing; the TX and RX functionality is implemented by the two instantiated modules.