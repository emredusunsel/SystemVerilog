# 8-to-3 Encoder

## Overview

This project implements an **8-to-3 binary encoder** in SystemVerilog. The encoder converts a **one-hot 8-bit input** into its corresponding **3-bit binary representation**. A `valid` output indicates whether the input contains a valid one-hot pattern.

The design is purely combinational and is intended for synthesis on FPGA or ASIC targets.

## Features

* 8-bit one-hot input
* 3-bit binary encoded output
* `valid` output for input validation
* Combinational implementation using `always_comb`
* Fully synthesizable

## Interface

| Signal  | Direction | Width | Description                                          |
| ------- | --------- | ----- | ---------------------------------------------------- |
| `D`     | Input     | 8     | One-hot input vector                                 |
| `Y`     | Output    | 3     | Binary index corresponding to the asserted input bit |
| `valid` | Output    | 1     | High when the input is a valid one-hot value         |

## Functionality

The encoder examines the 8-bit input `D` and produces the binary index of the asserted bit.

Only **one-hot** input patterns are considered valid:

| Input (`D`)     | Output (`Y`) | `valid` |
| --------------- | ------------ | :-----: |
| `00000001`      | `000`        |    1    |
| `00000010`      | `001`        |    1    |
| `00000100`      | `010`        |    1    |
| `00001000`      | `011`        |    1    |
| `00010000`      | `100`        |    1    |
| `00100000`      | `101`        |    1    |
| `01000000`      | `110`        |    1    |
| `10000000`      | `111`        |    1    |
| Any other value | `000`        |    0    |

If the input is:

* all zeros,
* multiple bits asserted, or
* any value other than a valid one-hot pattern,

the encoder drives `Y` to `000` and deasserts `valid`.

## Implementation

The encoder is implemented using a `case` statement inside an `always_comb` block. Each valid one-hot input pattern maps directly to its corresponding binary value. The `default` branch handles all invalid input combinations.

## Example

```systemverilog
logic [7:0] D;
logic [2:0] Y;
logic valid;

encoder dut (
    .D(D),
    .Y(Y),
    .valid(valid)
);

// Example
D = 8'b00100000;

// Outputs:
// Y     = 3'b101
// valid = 1
```

## Notes

* This implementation is a **standard encoder**, **not a priority encoder**.
* Exactly one input bit must be asserted for the output to be valid.
* Invalid input combinations are detected using the `default` branch of the `case` statement.
* The design is fully combinational and introduces no clock cycles or storage elements.
