# Parameterized Counter

## Overview

A parameterized **up/down counter** that increments or decrements its value on each rising clock edge when enabled.

The counting direction is controlled by `dir`.

## Features

* Parameterized counter width
* Up and down counting
* Enable control
* Active-low asynchronous reset
* Positive-edge triggered
* Fully synthesizable

## Parameters

| Parameter | Default | Description          |
| --------- | ------: | -------------------- |
| `WIDTH`   |       4 | Width of the counter |

## Interface

| Signal | Direction |   Width | Description                   |
| ------ | --------- | ------: | ----------------------------- |
| `clk`  | Input     |       1 | Clock                         |
| `rstn` | Input     |       1 | Active-low asynchronous reset |
| `en`   | Input     |       1 | Enables counting              |
| `dir`  | Input     |       1 | `0` = up, `1` = down          |
| `q`    | Output    | `WIDTH` | Current counter value         |

## Functionality

The counter updates on the rising edge of `clk` when `en` is high.

| `rstn` | `en` | `dir` | Operation    |
| :----: | :--: | :---: | ------------ |
|    0   |   X  |   X   | Reset to `0` |
|    1   |   0  |   X   | Hold value   |
|    1   |   1  |   0   | Increment    |
|    1   |   1  |   1   | Decrement    |

### Example

For `WIDTH = 4`:

```text
dir = 0: 0 → 1 → 2 → 3 → ... → 15 → 0
dir = 1: 15 → 14 → 13 → ... → 1 → 0 → 15
```

The counter naturally wraps around because `q` is an unsigned `WIDTH`-bit value.

## Implementation

The counter is implemented using an `always_ff` block.

* Reset asynchronously clears `q`.
* `en` controls whether the counter changes.
* `dir` selects between increment and decrement.
* When disabled, `q` retains its previous value.

## Example Instantiation

```systemverilog id="qf0x7p"
counter #(
    .WIDTH(8)
) dut (
    .clk (clk),
    .rstn(rstn),
    .en  (en),
    .dir (dir),
    .q   (q)
);
```

## Notes

* `dir = 0` counts upward.
* `dir = 1` counts downward.
* No explicit overflow or underflow detection is provided.
* The counter wraps naturally at the limits of its `WIDTH`.
