# Barrel Shifter

## Overview

A parameterized **barrel shifter** that performs a circular right shift on an input vector.

The amount of rotation is controlled by `shamt`, allowing the input to be shifted by multiple positions in a single combinational operation.

## Features

* Parameterized data width
* Circular right shift
* Variable shift amount
* Combinational implementation
* Fully synthesizable

## Parameters

| Parameter | Default | Description                        |
| --------- | ------: | ---------------------------------- |
| `WIDTH`   |       8 | Width of the input and output data |

## Interface

| Signal   | Direction |           Width | Description                         |
| -------- | --------- | --------------: | ----------------------------------- |
| `data`   | Input     |         `WIDTH` | Input data                          |
| `shamt`  | Input     | `$clog2(WIDTH)` | Number of positions to rotate right |
| `result` | Output    |         `WIDTH` | Rotated output                      |

## Functionality

The module performs a **circular right shift**:

```text
result = ROR(data, shamt)
```

Bits shifted out from the right side are wrapped around to the left side.

For example, with `WIDTH = 8`:

```text
data   = 10110001
shamt  = 2

result = 01101100
```

## Implementation

The barrel shifter is implemented as a series of combinational stages.

Each stage can rotate the data by a power of two:

```text
Stage 0 → rotate by 1
Stage 1 → rotate by 2
Stage 2 → rotate by 4
...
```

The corresponding bit of `shamt` determines whether each stage performs its rotation.

For example, with `WIDTH = 8`:

```text
shamt[0] → rotate by 1
shamt[1] → rotate by 2
shamt[2] → rotate by 4
```

The stages are generated using a `generate` loop, making the structure parameterized by `WIDTH`.

## Example

```systemverilog id="f2j7na"
logic [7:0] data;
logic [2:0] shamt;
logic [7:0] result;

barrel #(
    .WIDTH(8)
) dut (
    .data   (data),
    .shamt  (shamt),
    .result (result)
);
```

## Notes

* The operation is a **rotate right**, not a logical or arithmetic shift.
* No bits are lost during the operation.
* The design is purely combinational.
* The implementation is most naturally suited to widths that are powers of two because `shamt` is sized using `$clog2(WIDTH)`.
