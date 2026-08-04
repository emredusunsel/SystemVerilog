# 8-to-3 Priority Encoder (Casez Implementation)

## Overview

This project implements an **8-to-3 priority encoder** in SystemVerilog using the `casez` statement. Unlike a standard encoder, this design accepts input vectors with **multiple asserted bits** and outputs the index of the **highest-priority asserted bit**.

The priority is given to the **most significant bit (MSB)**, making the design suitable for interrupt handling, arbitration logic, and other priority-based digital circuits.

The module is purely combinational and fully synthesizable.

## Features

* 8-bit input vector
* 3-bit encoded output
* MSB has the highest priority
* `valid` output indicates whether any input bit is asserted
* Priority logic implemented using `casez`
* Fully synthesizable

## Interface

| Signal  | Direction | Width | Description                                       |
| ------- | --------- | ----- | ------------------------------------------------- |
| `d`     | Input     | 8     | Input vector                                      |
| `y`     | Output    | 3     | Binary index of the highest-priority asserted bit |
| `valid` | Output    | 1     | High when at least one input bit is asserted      |

## Functionality

The encoder evaluates the input vector using a `casez` statement. The `?` wildcard matches either `0` or `1`, allowing each pattern to represent all combinations where the corresponding bit is the highest asserted bit.

Because `case` statements are evaluated from top to bottom, the first matching pattern determines the output. The patterns are therefore ordered from **MSB to LSB**, giving higher-index bits higher priority.

### Truth Table Examples

| Input (`d`) | Output (`y`) | `valid` |
| ----------- | ------------ | :-----: |
| `00000000`  | `000`        |    0    |
| `00000001`  | `000`        |    1    |
| `00000110`  | `010`        |    1    |
| `00011010`  | `100`        |    1    |
| `01100101`  | `110`        |    1    |
| `11111111`  | `111`        |    1    |

For example:

* `d = 8'b00011010`
* Bits **1**, **3**, and **4** are asserted.
* Bit **4** has the highest priority.
* Output:

  * `y = 3'b100`
  * `valid = 1`

## Implementation

The encoder is implemented inside an `always_comb` block.

1. `y` and `valid` are initialized to zero.
2. A `casez` statement compares the input against wildcard patterns.
3. The first matching pattern assigns the encoded value and asserts `valid`.
4. If no bits are asserted, the default branch leaves the initialized values unchanged.

Using `casez` significantly simplifies the implementation compared to writing multiple conditional statements while clearly expressing the priority order.

## Example

```systemverilog
logic [7:0] d;
logic [2:0] y;
logic valid;

encoder dut (
    .d(d),
    .y(y),
    .valid(valid)
);

// Example
d = 8'b01010110;

// Outputs:
// y     = 3'b110
// valid = 1
```

## Notes

* This is a **priority encoder**, not a standard one-hot encoder.
* The **most significant asserted bit** has the highest priority.
* Multiple input bits may be asserted simultaneously.
* The `casez` statement uses `?` as a wildcard to match both `0` and `1`, enabling compact priority logic.
* The design is purely combinational and synthesizes efficiently into priority logic.
