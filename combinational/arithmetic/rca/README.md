# Ripple Carry Adder

## Overview

A parameterized **ripple carry adder (RCA)** that adds two `WIDTH`-bit binary numbers with a carry-in.

The design is constructed from multiple 1-bit `full_adder` modules. The carry output of each stage is connected to the carry input of the next stage.

## Features

* Parameterized operand width
* Supports carry-in and carry-out
* Built using `full_adder` instances
* Purely combinational
* Fully synthesizable

## Parameters

| Parameter | Default | Description                         |
| --------- | ------: | ----------------------------------- |
| `WIDTH`   |       4 | Width of the input operands and sum |

## Interface

| Signal | Direction |   Width | Description      |
| ------ | --------- | ------: | ---------------- |
| `a`    | Input     | `WIDTH` | First operand    |
| `b`    | Input     | `WIDTH` | Second operand   |
| `cin`  | Input     |       1 | Initial carry-in |
| `s`    | Output    | `WIDTH` | Sum result       |
| `cout` | Output    |       1 | Final carry-out  |

## Functionality

The RCA performs:

```text
a + b + cin = {cout, s}
```

For example, with `WIDTH = 4`:

```text
 a    = 1011
 b    = 0101
 cin  = 0
------------
       10000
```

Therefore:

```text
s    = 0000
cout = 1
```

## Implementation

The internal `carry` vector connects the full adders:

```text
cin → FA[0] → FA[1] → FA[2] → ... → FA[WIDTH-1] → cout
        ↓        ↓        ↓                 ↓
       s[0]     s[1]     s[2]              s[WIDTH-1]
```

Each generated `full_adder` operates on one bit of `a` and `b`.

* `carry[i]` is connected to `cin[i]`.
* Each full adder generates the carry for the next stage.
* `carry[WIDTH]` becomes `cout`.

The `generate` loop allows the same structure to be created automatically for any supported `WIDTH`.

## Example Instantiation

```systemverilog
rca #(
    .WIDTH(8)
) dut (
    .a    (),
    .b    (),
    .cin  (),
    .s    (),
    .cout ()
);
```

## Notes

* The design has no clock or reset.
* Carry propagates sequentially through the full-adder stages, which is why it is called a **ripple carry adder**.
* Larger widths increase the carry propagation delay.
* The module depends on the `full_adder` module being available during compilation.
