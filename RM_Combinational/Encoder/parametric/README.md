# Parameterized Priority Encoder

## Overview

This project implements a **parameterized priority encoder** in SystemVerilog. The encoder converts a binary input vector into the binary index of the **highest asserted bit**. The module supports configurable input widths through parameters, making it reusable for a variety of digital designs.

The design is purely combinational and is fully synthesizable.

## Features

* Parameterized input width
* Automatically calculated output width using `$clog2()`
* Priority encoding of multiple asserted inputs
* `valid` output indicating whether any input bit is asserted
* Combinational implementation using `always_comb`
* Fully synthesizable

## Parameters

| Parameter | Default         | Description                 |
| --------- | --------------- | --------------------------- |
| `WIDTH`   | `8`             | Width of the input vector   |
| `Y_WIDTH` | `$clog2(WIDTH)` | Width of the encoded output |

## Interface

| Signal  | Direction | Width     | Description                                    |
| ------- | --------- | --------- | ---------------------------------------------- |
| `d`     | Input     | `WIDTH`   | Input vector to be encoded                     |
| `y`     | Output    | `Y_WIDTH` | Binary index of the highest asserted input bit |
| `valid` | Output    | 1         | High when at least one input bit is asserted   |

## Functionality

The encoder scans the input vector from the least significant bit (LSB) to the most significant bit (MSB). Whenever an asserted bit is found, the output is updated with its index.

Because the loop continues through the entire input vector, the **highest-index asserted bit** has the highest priority and determines the final output.

### Example (WIDTH = 8)

| Input (`d`) | Output (`y`) | `valid` |
| ----------- | ------------ | :-----: |
| `00000000`  | `000`        |    0    |
| `00000001`  | `000`        |    1    |
| `00000100`  | `010`        |    1    |
| `00010100`  | `100`        |    1    |
| `11111111`  | `111`        |    1    |

For example:

* `d = 8'b00010100` has bits **2** and **4** asserted.
* Since bit **4** has the higher index, the encoder outputs:

  * `y = 3'b100`
  * `valid = 1`

## Implementation

The encoder is implemented with an `always_comb` block and a `for` loop.

1. `y` and `valid` are initialized to zero.
2. The input vector is scanned from bit `0` to `WIDTH-1`.
3. Whenever an asserted bit is encountered:

   * `y` is updated with the current bit index.
   * `valid` is asserted.
4. Since later iterations overwrite earlier ones, the highest asserted bit becomes the final encoded output.

## Example

```systemverilog
logic [7:0] d;
logic [2:0] y;
logic valid;

encoder #(
    .WIDTH(8)
) dut (
    .d(d),
    .y(y),
    .valid(valid)
);

// Example
d = 8'b01010010;

// Outputs:
// y     = 3'b110
// valid = 1
```

## Notes

* This implementation behaves as a **priority encoder**, where the **highest-index asserted bit** has the highest priority.
* Unlike a standard one-hot encoder, multiple input bits may be asserted simultaneously.
* If no input bits are asserted, `valid` is deasserted and `y` is driven to zero.
* The output width is automatically determined using `$clog2(WIDTH)`.
* The module is scalable and can be instantiated with any practical value of `WIDTH`.
