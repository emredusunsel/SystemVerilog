# Asynchronous FIFO

## Overview

A parameterized **asynchronous FIFO** for transferring data between two independent clock domains.

The FIFO uses separate write and read clocks, Gray-coded pointers, and 2-flip-flop synchronizers to safely communicate FIFO state information between the two clock domains.

## Features

- Independent write and read clock domains
- Gray-coded read and write pointers
- 2-flip-flop clock-domain synchronization
- Independent write and read resets
- Power-of-two depth requirement

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `WIDTH` | 8 | Width of each FIFO entry |
| `DEPTH` | 16 | Number of entries in the FIFO |

`DEPTH` must be greater than 2 and a power of two.

For example:

    DEPTH = 4
    DEPTH = 8
    DEPTH = 16
    DEPTH = 32

are valid configurations.

## Interface

### Write Domain

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `wr_clk` | Input | 1 | Write clock |
| `wr_rstn` | Input | 1 | Active-low write-domain reset |
| `wr_en` | Input | 1 | Write request |
| `wr_data` | Input | `WIDTH` | Data to write |
| `full` | Output | 1 | High when FIFO cannot accept another write |

### Read Domain

| Signal | Direction | Width | Description |
|---|---|---:|---|
| `rd_clk` | Input | 1 | Read clock |
| `rd_rstn` | Input | 1 | Active-low read-domain reset |
| `rd_en` | Input | 1 | Read request |
| `rd_data` | Output | `WIDTH` | Data read from the FIFO |
| `empty` | Output | 1 | High when FIFO contains no readable data |

## Architecture

The FIFO memory is shared between the two clock domains, while the control logic remains separated into write and read domains.

```text
                     ASYNCHRONOUS FIFO

             WRITE DOMAIN                 READ DOMAIN
          +----------------+           +----------------+
          |                |           |                |
wr_clk -->|  Write Pointer |           |  Read Pointer  |<-- rd_clk
          |     Binary     |           |     Binary     |
          +-------+--------+           +--------+-------+
                  |                             |
                  v                             v
          +----------------+           +----------------+
          | Gray Conversion|           | Gray Conversion|
          +-------+--------+           +--------+-------+
                  |                             |
                  |                             |
                  v                             v
             Synchronizer                  Synchronizer
                  |                             |
                  v                             v
             Read Domain                  Write Domain
               Logic                        Logic

                    +------------------+
                    |       MEM        |
                    |                  |
                    | WIDTH x DEPTH    |
                    +------------------+
```

The write pointer is synchronized into the read clock domain, while the read pointer is synchronized into the write clock domain.

## Write Side

The write side operates entirely using `wr_clk`.

When:

    wr_en = 1
    full  = 0

the input data is written into the FIFO memory.

The write pointer then advances.

The memory address is taken from the lower bits of the binary write pointer:

    mem[wr_ptr[ADDR_WIDTH-1:0]]

Writes are blocked when `full` is asserted.

## Read Side

The read side operates using `rd_clk`.

When:

    rd_en = 1
    empty = 0

data is read from the FIFO memory and placed on `rd_data`.

The read pointer then advances.

Reads are blocked when `empty` is asserted.

## Binary Pointers

The FIFO maintains separate binary pointers:

    wr_ptr
    rd_ptr

An additional pointer bit is used to distinguish between different wrap-around conditions.

The pointer width is:

    PTR_WIDTH = $clog2(DEPTH) + 1

The lower bits select the memory location, while the additional bit is used for full/empty detection.

## Gray Coding

Binary pointers are converted to Gray code using:

    gray_ptr = binary_ptr ^ (binary_ptr >> 1)

The module generates:

    gray_wr_ptr
    gray_rd_ptr

Gray code is used because only one bit changes when the pointer advances by one position.

This makes the pointer safer to synchronize between asynchronous clock domains.

## Clock-Domain Synchronization

The write pointer is transferred into the read domain:

    gray_wr_ptr
        |
        v
    wr_sync1
        |
        v
    wr_sync2

The read pointer is transferred into the write domain:

    gray_rd_ptr
        |
        v
    rd_sync1
        |
        v
    rd_sync2

Each pointer uses a two-flip-flop synchronizer.

The synchronized pointer is then used by the receiving clock domain for FIFO status generation.

## Empty Detection

The FIFO is empty when the current read pointer matches the synchronized write pointer:

    empty = (gray_rd_ptr == wr_sync2)

This means there are no additional entries available to read in the read clock domain.

Because the write pointer must cross the clock-domain synchronizer, `empty` can remain asserted for a short period after a new write occurs.

## Full Detection

The FIFO is full when the next write pointer reaches the read pointer with the appropriate wrap-around condition.

The next write pointer is calculated using:

    next_wr_ptr = wr_ptr + (wr_en && !full)

It is then converted to Gray code:

    next_wr_gray = next_wr_ptr ^ (next_wr_ptr >> 1)

The next Gray-coded write pointer is compared against the synchronized read pointer to generate `next_full`.

This allows `full` to indicate whether accepting the next write would fill the FIFO.

## Write and Read Timing

The two sides operate independently.

For example:

```text
wr_clk:  _|‾|_|‾|_|‾|_|‾|_|‾|_
rd_clk:  __|‾‾|__|‾‾|__|‾‾|__

write -->     data enters FIFO
read  ---------------------> data becomes available
```

The write and read clocks do not need to have the same frequency or phase.

## Reset

The FIFO has independent resets for the two clock domains:

    wr_rstn
    rd_rstn

The write-domain reset initializes:

- Write pointer
- `full`
- Write-side synchronizer

The read-domain reset initializes:

- Read pointer
- `rd_data`
- Read-side synchronizer

The FIFO memory itself is **not reset**. Only the control state is reset.

This is intentional because the contents of memory are irrelevant while the FIFO is empty.

## Example Instantiation

```systemverilog
logic       wr_clk;
logic       wr_rstn;
logic       wr_en;
logic [7:0] wr_data;
logic       full;

logic       rd_clk;
logic       rd_rstn;
logic       rd_en;
logic [7:0] rd_data;
logic       empty;

async_fifo #(
    .WIDTH (8),
    .DEPTH (16)
) dut (
    .wr_clk  (wr_clk),
    .wr_rstn (wr_rstn),
    .wr_en   (wr_en),
    .wr_data (wr_data),
    .full    (full),

    .rd_clk  (rd_clk),
    .rd_rstn (rd_rstn),
    .rd_en   (rd_en),
    .rd_data (rd_data),
    .empty   (empty)
);
```

### Writing Data

A write is accepted when:

    wr_en = 1
    full  = 0

For example:

    wr_data = 8'hA5
    wr_en   = 1

On the next active `wr_clk` edge, the data is stored in the FIFO.

### Reading Data

A read is accepted when:

    rd_en = 1
    empty = 0

On the next active `rd_clk` edge, the corresponding FIFO entry is placed on `rd_data`.

## Notes

- `DEPTH` must be greater than 2 and a power of two.
- Write and read clocks can operate at different frequencies.
- The FIFO uses Gray-coded pointers for clock-domain crossing.
- Each pointer crosses into the opposite clock domain through a 2-flip-flop synchronizer.
- `full` is generated in the write clock domain.
- `empty` is generated in the read clock domain.
- Writes are ignored when `full` is asserted.
- Reads are ignored when `empty` is asserted.
- The FIFO memory is not reset because its contents are invalid whenever the FIFO is empty.
- Due to clock-domain synchronization latency, `full` and `empty` do not necessarily change immediately after an operation in the opposite clock domain.
