# FIFO

## Overview

A parameterized **synchronous FIFO (First-In, First-Out)** buffer for storing and retrieving data in order.

Data is written when `wr_en` is asserted and the FIFO is not full. Data is read when `rd_en` is asserted and the FIFO is not empty.

## Features

* Parameterized data width and depth
* Synchronous read and write
* `full` and `empty` status flags
* Active-low asynchronous reset
* Fully synthesizable

## Parameters

| Parameter | Default | Description                    |
| --------- | ------: | ------------------------------ |
| `WIDTH`   |       8 | Width of each stored data word |
| `DEPTH`   |      16 | Number of entries in the FIFO  |

## Interface

| Signal   | Direction |   Width | Description                   |
| -------- | --------- | ------: | ----------------------------- |
| `clk`    | Input     |       1 | Clock                         |
| `rstn`   | Input     |       1 | Active-low asynchronous reset |
| `data_i` | Input     | `WIDTH` | Data to write                 |
| `wr_en`  | Input     |       1 | Write enable                  |
| `rd_en`  | Input     |       1 | Read enable                   |
| `data_o` | Output    | `WIDTH` | Data read from FIFO           |
| `empty`  | Output    |       1 | High when FIFO is empty       |
| `full`   | Output    |       1 | High when FIFO is full        |

## Functionality

### Write

A write occurs when:

```text
wr_en & !full
```

`data_i` is stored at the current write pointer, and the write pointer advances.

### Read

A read occurs when:

```text
rd_en & !empty
```

The data at the current read pointer is placed on `data_o`, and the read pointer advances.

### Status Flags

```text
empty = 1  →  count = 0
full  = 1  →  count = DEPTH
```

The `count` tracks the current number of stored entries.

## Implementation

The FIFO consists of:

* **Memory array** — stores the data.
* **Write pointer** — selects where new data is written.
* **Read pointer** — selects which data is read.
* **Counter** — tracks the number of stored entries.

The counter is updated according to the successful read/write operations:

| Write | Read | Counter   |
| :---: | :--: | --------- |
|   0   |   0  | Unchanged |
|   1   |   0  | Increment |
|   0   |   1  | Decrement |
|   1   |   1  | Unchanged |

A simultaneous valid read and write therefore keeps the FIFO occupancy unchanged.

## Example Instantiation

```systemverilog
fifo #(
    .WIDTH (8),
    .DEPTH (16)
) dut (
    .clk    (),
    .rstn   (),
    .data_i (),
    .wr_en  (),
    .rd_en  (),
    .data_o (),
    .empty  (),
    .full   ()
);
```

## Notes

* The FIFO follows **first-in, first-out** ordering.
* Writes are ignored when the FIFO is full.
* Reads are ignored when the FIFO is empty.
* `data_o` is updated on a successful read.
* Both read and write operations occur on the rising edge of `clk`.
* The implementation uses a counter to determine `full` and `empty`.
