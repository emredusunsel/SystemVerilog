# Parameterized Priority Encoder

## Overview

A parameterized **priority encoder** that converts an input vector into the binary index of the highest-priority asserted bit.

The encoder checks the input from **MSB to LSB**, giving the highest-index bit the highest priority.

## Features

* Parameterized input width
* MSB-first priority
* Binary encoded output
* `valid` signal
* Supports multiple asserted inputs
* Combinational and fully synthesizable

## Parameters

| Parameter | Default | Description               |
| --------- | ------: | ------------------------- |
| `WIDTH`   |       8 | Width of the input vector |

## Interface

| Signal    | Direction |           Width | Description                             |
| --------- | --------- | --------------: | --------------------------------------- |
| `data`    | Input     |         `WIDTH` | Input request vector                    |
| `encoded` | Output    | `$clog2(WIDTH)` | Index of the highest-priority `1`       |
| `valid`   | Output    |               1 | High when at least one input bit is `1` |

## Functionality

The encoder searches `data` from `WIDTH-1` down to `0`.

The first `1` found becomes the encoded output.

For `WIDTH = 8`:

| `data`     | `encoded` | `valid` |
| ---------- | --------: | :-----: |
| `00000000` |     `000` |    0    |
| `00000001` |     `000` |    1    |
| `00000100` |     `010` |    1    |
| `00010100` |     `100` |    1    |
| `10100100` |     `111` |    1    |
| `11111111` |     `111` |    1    |

For example:

```text
data    = 10100100
          ↑
        bit 7
```

Since bit `7` is the highest asserted bit:

```text
encoded = 111
valid   = 1
```

## Implementation

The module uses a `for` loop to scan the input from MSB to LSB.

A `first_flag` prevents lower-priority bits from overwriting the result after the first asserted bit is found.

```text
MSB ───────────────────► LSB
     highest priority
```

If no bit is asserted, `valid` remains `0` and `encoded` remains `0`.

## Example Instantiation

```systemverilog
encoder #(
    .WIDTH(8)
) dut (
    .data    (data),
    .encoded (encoded),
    .valid   (valid)
);
```

## Notes

* The **MSB has the highest priority**.
* Multiple input bits can be asserted simultaneously.
* Only the highest asserted bit is encoded.
* `valid = 0` when `data` is all zeros.
* The design is purely combinational.
