# Single-Port RAM

## Overview

A parameterized **single-port synchronous RAM (SPRAM)** with separate read and write controls.

The memory uses a single clock and supports either a write or a read operation on each clock cycle.

## Features

- Parameterized data width
- Parameterized memory depth
- Synchronous read
- Synchronous write
- Single memory port
- Enable control
- Write enable control
- Active-low reset for `rd_data`
- Power-of-two depth requirement
- Parameter validation

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `WIDTH` | 8 | Number of bits per memory word |
| `DEPTH` | 16 | Number of addressable memory locations |

The current implementation requires:

    WIDTH >= 1
    DEPTH > 2
    DEPTH = power of two

## Interface

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | Memory clock |
| `rstn` | Input | 1 | Active-low reset |
| `en` | Input | 1 | Enables the memory operation |
| `we` | Input | 1 | Selects write operation |
| `addr` | Input | `$clog(DEPTH)` | Memory address |
| `wr_data` | Input | `WIDTH` | Data to write |
| `rd_data` | Output | `WIDTH` | Data read from memory |

## Operation

The memory operation is selected using `en` and `we`.

| `en` | `we` | Operation |
|:---:|:---:|---|
| 0 | X | No operation |
| 1 | 0 | Read |
| 1 | 1 | Write |

### Write

When:

    en = 1
    we = 1

the input data is written to the selected memory location on the rising edge of `clk`.

Conceptually:

    mem[addr] <= wr_data

### Read

When:

    en = 1
    we = 0

the selected memory location is read on the rising edge of `clk`.

The result is registered on `rd_data`:

    rd_data <= mem[addr]

Therefore, the read operation is **synchronous**.

## Timing

A read request is sampled on the rising edge of `clk`.

For example:

    Cycle N:
        en   = 1
        we   = 0
        addr = A

    Rising edge:
        mem[A] is read

    After the edge:
        rd_data = mem[A]

The output therefore does not change asynchronously with the address.

## Memory Structure

The memory is represented as:

    logic [WIDTH-1:0] mem [DEPTH];

For the default configuration:

    WIDTH = 8
    DEPTH = 16

the memory contains:

    16 words
    8 bits per word

with addresses:

    0 -> 15

## Reset

The reset is active-low.

When `rstn` is low on a clock edge:

    rd_data = 0

The memory contents themselves are **not reset**.

This avoids unnecessary hardware for clearing every memory location. Only the output register is reset.

## Parameter Validation

The module performs elaboration-time checks for the supported parameter ranges.

`WIDTH` must be at least 1:

    WIDTH >= 1

`DEPTH` must be greater than 2 and a power of two:

    DEPTH > 2
    DEPTH & (DEPTH - 1) == 0

Invalid configurations terminate simulation with `$fatal`.

## Example Instantiation

    ```systemverilog
    logic       clk;
    logic       rstn;
    logic       en;
    logic       we;
    logic [3:0] addr;
    logic [7:0] wr_data;
    logic [7:0] rd_data;

    spram #(
        .WIDTH (8),
        .DEPTH (16)
    ) dut (
        .clk     (clk),
        .rstn    (rstn),
        .en      (en),
        .we      (we),
        .addr    (addr),
        .wr_data (wr_data),
        .rd_data (rd_data)
    );
    ```

### Write Example

To write `8'hA5` to address `4`:

    en      = 1
    we      = 1
    addr    = 4
    wr_data = 8'hA5

On the next rising clock edge:

    mem[4] = 8'hA5

### Read Example

To read address `4`:

    en   = 1
    we   = 0
    addr = 4

On the next rising clock edge:

    rd_data = mem[4]

## Notes

- This is a **single-port RAM**, so each clock cycle performs at most one memory operation.
- Read and write operations are mutually exclusive through `we`.
- Reads are synchronous and the result is registered in `rd_data`.
- Writes occur on the rising edge of `clk`.
- The memory contents are not reset.
- `rd_data` is reset to zero.
- `en = 0` holds the current `rd_data` value and performs no memory operation.
