# Dual-Port RAM

## Overview

A parameterized **dual-port RAM (DPRAM)** with independent read and write addresses.

The module uses a single clock and provides separate read and write enables, allowing read and write operations to occur in the same clock cycle.

## Features

- Parameterized data width/memory depth
- Separate read and write addresses
- Independent read and write enables
- Synchronous read/write
- Same-address read/write handling
- Active-low reset for `rd_data`
- Power-of-two depth requirement
- Parameter validation

## Parameters

| Parameter | Default | Description                    |
|-----------|--------:|--------------------------------|
| `WIDTH`   | 8       | Number of bits per memory word |
| `DEPTH`   | 16      | Number of memory locations     |

The current implementation requires:

- `WIDTH >= 1`
- `DEPTH >= 2`
- `DEPTH` must be a power of two

## Interface

| Signal    | Direction | Width           | Description          |
|-----------|-----------|----------------:|----------------------|
| `clk`     | Input     | 1               | Memory clock         |
| `rstn`    | Input     | 1               | Active-low reset     |
| `wr_en`   | Input     | 1               | Enables a write      |
| `wr_addr` | Input     | `$clog2(DEPTH)` | Write address        |
| `wr_data` | Input     | `WIDTH`         | Data to write        |
| `rd_en`   | Input     | 1               | Enables a read       |
| `rd_addr` | Input     | `$clog2(DEPTH)` | Read address         |
| `rd_data` | Output    | `WIDTH`         | Registered read data |

## Operation

The RAM provides separate read and write ports.

A write uses:

- `wr_en`
- `wr_addr`
- `wr_data`

A read uses:

- `rd_en`
- `rd_addr`

Both operations are controlled by the same clock.

## Write Operation

When `wr_en` is high, `wr_data` is written to the memory location selected by `wr_addr` on the rising edge of `clk`.

```text
wr_en = 1
wr_addr = address
wr_data = data

       |
       v

mem[wr_addr] = wr_data
```

## Read Operation

When `rd_en` is high, the memory location selected by `rd_addr` is read on the rising edge of `clk`.

The result is registered on `rd_data`.

```text
rd_en = 1
rd_addr = address

       |
       v

rd_data = mem[rd_addr]
```

The read operation is therefore synchronous.

## Simultaneous Read and Write

Because the RAM has separate read and write addresses, a read and write can occur during the same clock cycle.

When:

```text
wr_addr != rd_addr
```

the two operations are independent.

```text
                 +----------------+
wr_addr -------->|                |
wr_data -------->|     MEMORY     |
wr_en ---------->|                |
                 |                |
rd_addr -------->|                |
rd_en ---------->|                |
                 +-------+--------+
                         |
                         v
                      rd_data
```

## Same-Address Access

The module explicitly handles the case where:

```text
wr_addr == rd_addr
```

### Write Only

When:

```text
wr_en = 1
rd_en = 0
```

the new data is written to the selected location.

### Read Only

When:

```text
wr_en = 0
rd_en = 1
```

the existing memory contents are returned through `rd_data`.

### Simultaneous Read and Write

When:

```text
wr_en = 1
rd_en = 1
wr_addr == rd_addr
```

the module uses **write-first behavior**.

The newly written value is returned on `rd_data`:

```text
rd_data <= wr_data
```

This avoids relying on unspecified memory read-during-write behavior.

## Operation Table

| `wr_en` | `rd_en` | Address Relation | Operation                           |
|:-------:|:-------:|------------------|-------------------------------------|
| 0       | 0       | Any              | No operation                        |
| 1       | 0       | Any              | Write                               |
| 0       | 1       | Any              | Read                                |
| 1       | 1       | Different        | Read and write simultaneously       |
| 1       | 1       | Same             | Write new data and return `wr_data` |

## Timing

Both read and write operations occur on the rising edge of `clk`.

For a read:

```text
Cycle N:
    rd_en   = 1
    rd_addr = A

Rising edge:
    mem[A] is read

After the edge:
    rd_data = mem[A]
```

The read data is therefore registered rather than continuously driven from the memory.

## Reset

The reset is active-low.

When `rstn` is low on a clock edge:

```text
rd_data = 0
```

The memory contents themselves are **not reset**.

Only the output register is initialized by reset.

This avoids the hardware cost of clearing every memory location.

## Memory Structure

The memory is represented as:

```text
logic [WIDTH-1:0] mem [DEPTH];
```

With the default configuration:

```text
WIDTH = 8
DEPTH = 16
```

the RAM contains 16 words with 8 bits per word.

The valid addresses are:

```text
0 -> 15
```

## Parameter Validation

The module checks the supported parameter ranges during elaboration.

`WIDTH` must be at least 1:

```text
WIDTH >= 1
```

`DEPTH` must be at least 2 and a power of two:

```text
DEPTH >= 2
DEPTH = power of two
```

Invalid configurations terminate simulation with `$fatal`.

## Example Instantiation

```systemverilog
logic       clk;
logic       rstn;

logic       wr_en;
logic [3:0] wr_addr;
logic [7:0] wr_data;

logic       rd_en;
logic [3:0] rd_addr;
logic [7:0] rd_data;

dpram #(
    .WIDTH (8),
    .DEPTH (16)
) dut (
    .clk     (clk),
    .rstn    (rstn),

    .wr_en   (wr_en),
    .wr_addr (wr_addr),
    .wr_data (wr_data),

    .rd_en   (rd_en),
    .rd_addr (rd_addr),
    .rd_data (rd_data)
);
```

### Write Example

To write `8'hA5` to address `4`:

```text
wr_en   = 1
wr_addr = 4
wr_data = 8'hA5
```

On the next rising edge:

```text
mem[4] = 8'hA5
```

### Read Example

To read address `4`:

```text
rd_en   = 1
rd_addr = 4
```

On the next rising edge:

```text
rd_data = mem[4]
```

### Simultaneous Same-Address Example

If:

```text
wr_en   = 1
rd_en   = 1
wr_addr = 4
rd_addr = 4
wr_data = 8'h3C
```

then on the clock edge:

```text
mem[4]  = 8'h3C
rd_data = 8'h3C
```

The new write data is returned through the registered read output.

## Notes

- This is a single-clock dual-port RAM.
- Read and write addresses are independent.
- Read and write operations can occur simultaneously.
- Reads are synchronous.
- Writes occur on the rising edge of `clk`.
- Same-address simultaneous read/write uses write-first behavior.
- The memory contents are not reset.
- `rd_data` is reset to zero.
- `wr_en` and `rd_en` independently control the two ports.
- `DEPTH` must be a power of two.
