# First-Word Fall-Through FIFO

## Overview

A parameterized **First-Word Fall-Through (FWFT) FIFO** that makes the first stored word immediately available on `rd_data` without requiring a read operation to load it.

The FIFO uses a single clock domain and maintains independent read and write pointers together with an entry counter.

## Features

* Parameterized data width
* Parameterized FIFO depth
* First-word fall-through behavior
* Single clock domain
* Synchronous write and read control
* Full and empty status signals
* Simultaneous read/write support
* Active-low asynchronous reset
* Power-of-two depth requirement

## Parameters

| Parameter | Default | Description                   |
|-----------|--------:|-------------------------------|
| `WIDTH`   |       8 | Width of each FIFO entry      |
| `DEPTH`   |      16 | Number of entries in the FIFO |

`DEPTH` must be greater than 2 and a power of two.

Valid examples:

    DEPTH = 4
    DEPTH = 8
    DEPTH = 16
    DEPTH = 32

## Interface

| Signal    | Direction |   Width | Description                   |
|-----------|-----------|--------:|-------------------------------|
| `clk`     | Input     |       1 | FIFO clock                    |
| `rstn`    | Input     |       1 | Active-low asynchronous reset |
| `wr_en`   | Input     |       1 | Write request                 |
| `wr_data` | Input     | `WIDTH` | Data to write                 |
| `rd_en`   | Input     |       1 | Read request                  |
| `rd_data` | Output    | `WIDTH` | Current first FIFO word       |
| `full`    | Output    |       1 | High when FIFO is full        |
| `empty`   | Output    |       1 | High when FIFO is empty       |

## FWFT Behavior

Unlike a conventional FIFO, the first available word does not need to be explicitly read into `rd_data`.

When the FIFO contains data:

    empty = 0

and:

    rd_data = first available word

The consumer can therefore inspect `rd_data` before asserting `rd_en`.

A read operation advances the read pointer and exposes the next FIFO word.

## Basic Operation

### Write

A write is accepted when:

    wr_en = 1
    full  = 0

The input data is stored at the current write pointer:

    mem[wr_ptr] <= wr_data

The write pointer and FIFO entry count are then advanced.

### Read

When:

    rd_en = 1
    empty = 0

the read pointer advances and the FIFO count decreases.

Because this is an FWFT FIFO, `rd_data` is continuously driven from the current FIFO location.

## FIFO States

The FIFO can be viewed as having three important conditions:

| Condition      | `empty` | `full` | Description                   |
|----------------|:-------:|:------:|-------------------------------|
| Empty          | 1       | 0      | No valid data available       |
| Partially full | 0       | 0      | Data available for reading    |
| Full           | 0       | 1      | No additional writes accepted |

## Pointer and Counter

The FIFO uses:

* `wr_ptr` — points to the next write location
* `rd_ptr` — points to the current read location
* `ptr_cnt` — tracks the number of stored entries

The pointers contain an additional bit beyond the memory address width.

This allows the design to distinguish between the normal and wrapped pointer positions when generating `full`.

The memory address is taken from the lower pointer bits.

## Full Detection

The FIFO is full when the write and read pointers have the same memory address but different wrap bits.

Conceptually:

    write address == read address
    write wrap bit != read wrap bit

This corresponds to the FIFO containing `DEPTH` entries.

## Empty Detection

The FIFO is empty when the entry count reaches zero.

The `empty` flag is updated based on the current FIFO occupancy and read/write operations.

After the first successful write into an empty FIFO:

    empty = 0

and the newly written word becomes available through `rd_data`.

Even though the word is immediately visible on the ouput, `empty` is not asserted until `rd_en` is asserted. In short, `rd_en` means consume data, `empty` means all data are consumed.

## Simultaneous Read and Write

The FIFO explicitly handles simultaneous read and write operations.

### Non-Empty FIFO

When both:

    wr_en = 1
    rd_en = 1

and the FIFO already contains data, one existing word is consumed while the new word is added.

Therefore, the FIFO occupancy remains unchanged.

Conceptually:

    count -> count

while:

    wr_ptr -> next location
    rd_ptr -> next location

### Empty FIFO

A special case occurs when both read and write are asserted while the FIFO is empty.

The new data is accepted, but the newly written word is **not consumed by the same-cycle read request**.

The write is therefore treated as the first valid FIFO entry:

    empty -> 0
    count -> 1

This ensures that a read request cannot consume data that was not already available at the beginning of the cycle.

## First-Word Fall-Through Data Path

The output is continuously selected from the FIFO memory:

    rd_data = empty ? previous_read_location : current_read_location

When the FIFO is non-empty, `rd_data` directly reflects the memory location addressed by `rd_ptr`.

When the FIFO becomes empty after the final read, the previous memory location is selected so that the output retains the last stored word instead of becoming an invalid memory location.

## Reset

The FIFO uses an active-low asynchronous reset.

On reset:

    wr_ptr  = 0
    rd_ptr  = 0
    ptr_cnt = 0
    empty   = 1

The FIFO memory itself is not reset.

This is intentional because memory contents are irrelevant while the FIFO is empty.

## Example Instantiation

```systemverilog
    logic       clk;
    logic       rstn;
    logic       wr_en;
    logic [7:0] wr_data;
    logic       rd_en;
    logic [7:0] rd_data;
    logic       full;
    logic       empty;

    fwft_fifo #(
        .WIDTH (8),
        .DEPTH (16)
    ) dut (
        .clk     (clk),
        .rstn    (rstn),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .rd_en   (rd_en),
        .rd_data (rd_data),
        .full    (full),
        .empty   (empty)
    );
```

### Example Sequence

Initially:

    empty = 1

Write:

    wr_data = 8'hA5
    wr_en   = 1

After the write is accepted:

    empty  = 0
    rd_data = 8'hA5

The first word is therefore available without asserting `rd_en`.

When:

    rd_en = 1

the FIFO consumes the current word and advances to the next entry.

## Notes

* The FIFO is single-clock; both read and write operations use `clk`.
* `rd_data` provides first-word fall-through behavior.
* `rd_en` consumes the currently available word.
* Simultaneous read/write operations are explicitly handled.
* A simultaneous read/write while empty accepts the write but does not consume the newly written word.
* The FIFO memory is not reset.
* `DEPTH` must be greater than 2 and a power of two.
