# D Flip-Flop

## Overview

A 1-bit **D flip-flop** with an enable input and an active-low asynchronous reset.

The input `d` is stored in `q` on the rising edge of `clk` when `en` is asserted.

## Features

* 1-bit storage
* Enable control
* Active-low asynchronous reset
* Positive-edge triggered
* Fully synthesizable

## Interface

| Signal | Direction | Description                   |
| ------ | --------- | ----------------------------- |
| `clk`  | Input     | Clock                         |
| `rstn` | Input     | Active-low asynchronous reset |
| `en`   | Input     | Enable for updating `q`       |
| `d`    | Input     | Data input                    |
| `q`    | Output    | Stored data                   |

## Functionality

The flip-flop operates as follows:

| Condition                          | `q`                  |
| ---------------------------------- | -------------------- |
| `rstn = 0`                         | `0`                  |
| `rstn = 1`, rising `clk`, `en = 1` | `d`                  |
| `rstn = 1`, rising `clk`, `en = 0` | Holds previous value |

The reset has priority over the enable.

## Implementation

The flip-flop is implemented using `always_ff` with:

* `posedge clk` for normal operation
* `negedge rstn` for asynchronous reset

When `en` is low, there is no assignment to `q`, so the flip-flop retains its previous value.

## Example

```systemverilog
logic clk;
logic rstn;
logic en;
logic d;
logic q;

dff dut (
    .clk  (clk),
    .rstn (rstn),
    .en   (en),
    .d    (d),
    .q    (q)
);
```

## Notes

* Reset is **asynchronous** and active-low.
* Data is captured only on the rising edge of `clk`.
* When `en = 0`, the current value of `q` is preserved.
