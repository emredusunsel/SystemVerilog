# Parameterized Decoder

## Overview

A parameterized **binary-to-one-hot decoder** that converts a `DEPTH`-bit address into a `WIDTH`-bit one-hot output.

When `en` is high, exactly one output bit corresponding to `addr` is asserted.

## Features

* Parameterized output width
* One-hot output
* Enable control
* Combinational implementation
* Fully synthesizable

## Parameters

| Parameter |         Default | Description                |
| --------- | --------------: | -------------------------- |
| `WIDTH`   |               8 | Number of decoder outputs  |
| `DEPTH`   | `$clog2(WIDTH)` | Width of the input address |

## Interface

| Signal | Direction |   Width | Description            |
| ------ | --------- | ------: | ---------------------- |
| `addr` | Input     | `DEPTH` | Selects the output bit |
| `en`   | Input     |       1 | Enables the decoder    |
| `out`  | Output    | `WIDTH` | One-hot decoded output |

## Functionality

When `en = 1`, the bit at position `addr` is set:

```text
out[addr] = 1
```

All other output bits are `0`.

When `en = 0`, all outputs are cleared.

### Example

For `WIDTH = 8`:

| `en` | `addr` | `out`      |
| :--: | :----: | ---------- |
|   0  |  `xxx` | `00000000` |
|   1  |  `000` | `00000001` |
|   1  |  `001` | `00000010` |
|   1  |  `010` | `00000100` |
|   1  |  `011` | `00001000` |
|   1  |  `100` | `00010000` |
|   1  |  `101` | `00100000` |
|   1  |  `110` | `01000000` |
|   1  |  `111` | `10000000` |

## Implementation

The decoder creates a one-hot value by shifting a single `1` by `addr` positions:

```systemverilog
assign out = en ? ({{(WIDTH-1){1'b0}}, 1'b1} << addr) : '0;
```

The enable signal determines whether the decoded output is generated or cleared.

## Example Instantiation

```systemverilog
decoder #(
    .WIDTH(8)
) dut (
    .addr (addr),
    .en   (en),
    .out  (out)
);
```

## Notes

* The output is **one-hot** when enabled.
* The design is purely combinational.
* `WIDTH` should be chosen appropriately for the address range.
* For non-power-of-two `WIDTH` values, some address combinations do not correspond to a valid output bit.
