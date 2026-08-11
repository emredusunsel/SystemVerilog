# Synchronous RAM

## Overview

A parameterized single-port RAM module with configurable address and data widths.

The memory supports write operations through `cs` and `we`, while read data is available when the module is selected for a read operation.

## Features

* Parameterized memory size
* Parameterized data width
* Single-port memory interface
* Write operation on the rising clock edge
* Chip-select and write-enable controls
* Fully synthesizable

## Parameters

| Parameter    |         Default | Description                |
| ------------ | --------------: | -------------------------- |
| `ADDR_WIDTH` |               4 | Width of the address       |
| `DATA_WIDTH` |               8 | Width of each memory word  |
| `DEPTH`      | `2**ADDR_WIDTH` | Number of memory locations |

## Interface

| Signal   | Direction |        Width | Description    |
| -------- | --------- | -----------: | -------------- |
| `clk`    | Input     |            1 | Clock          |
| `addr`   | Input     | `ADDR_WIDTH` | Memory address |
| `data_i` | Input     | `DATA_WIDTH` | Data to write  |
| `cs`     | Input     |            1 | Chip select    |
| `we`     | Input     |            1 | Write enable   |
| `data_o` | Output    | `DATA_WIDTH` | Read data      |

## Functionality

### Write

A write occurs on the rising edge of `clk` when both `cs` and `we` are high:

```text
cs = 1
we = 1
```

The input data is stored at the selected address.

### Read

When `cs` is high and `we` is low, the memory contents at `addr` are connected to `data_o`:

```text
cs = 1
we = 0
```

Otherwise, `data_o` is driven to zero.

| `cs` | `we` | Operation    |
| :--: | :--: | ------------ |
|   0  |   0  | Output = 0   |
|   0  |   1  | No operation |
|   1  |   0  | Read         |
|   1  |   1  | Write        |

## Implementation

The memory is declared as an array:

```text
mem[0] ... mem[DEPTH-1]
```

Writes are performed inside an `always_ff` block, making them clocked operations.

The read path uses a continuous assignment, so the selected memory location is directly reflected on `data_o` when the RAM is enabled for reading.

## Example

```systemverilog
logic        clk;
logic [3:0]  addr;
logic [7:0]  data_i;
logic        cs;
logic        we;
logic [7:0]  data_o;

sync_ram #(
    .ADDR_WIDTH (4),
    .DATA_WIDTH (8)
) dut (
    .clk   (clk),
    .addr  (addr),
    .data_i(data_i),
    .cs    (cs),
    .we    (we),
    .data_o(data_o)
);
```

## Notes

* Write operations occur on the rising edge of `clk`.
* The read path in this implementation is **asynchronous**, despite the module name `sync_ram`.
* `data_o` is zero when the RAM is not selected for reading.
* `DEPTH` defaults to `2**ADDR_WIDTH`.
* This structure can be inferred as block/distributed RAM depending on the target device and synthesis tool.
