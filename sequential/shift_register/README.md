# Parameterized Shift Register

## Overview

A parameterized **shift register** that shifts data left or right by one bit on each enabled clock cycle.

The `dir` input selects the shift direction, while `serial_in` provides the new bit inserted into the register.

## Features

* Parameterized register width
* Shift left and right
* Serial data input
* Enable control
* Active-low asynchronous reset
* Positive-edge triggered
* Fully synthesizable

## Parameters

| Parameter | Default | Description                                      |
| --------- | ------: | ------------------------------------------------ |
| `WIDTH`   |       8 | Width of the shift register. Must be at least 2. |

## Interface

| Signal      | Direction |   Width | Description                         |
| ----------- | --------- | ------: | ----------------------------------- |
| `clk`       | Input     |       1 | Clock                               |
| `rstn`      | Input     |       1 | Active-low asynchronous reset       |
| `en`        | Input     |       1 | Enables shifting                    |
| `serial_in` | Input     |       1 | Bit inserted during shifting        |
| `dir`       | Input     |       1 | `0` = shift right, `1` = shift left |
| `q`         | Output    | `WIDTH` | Current register contents           |

## Functionality

When `en = 1`, the register shifts by one position on each rising clock edge.

### Shift Right

When `dir = 0`:

```text
q <= {serial_in, q[WIDTH-1:1]}
```

The new `serial_in` bit enters from the **MSB side**.

### Shift Left

When `dir = 1`:

```text
q <= {q[WIDTH-2:0], serial_in}
```

The new `serial_in` bit enters from the **LSB side**.

| `rstn` | `en` | Operation                |
| :----: | :--: | ------------------------ |
|    0   |   X  | Reset `q` to 0           |
|    1   |   0  | Hold current value       |
|    1   |   1  | Shift according to `dir` |

## Example Instantiation

```systemverilog
shift_register #(
    .WIDTH(8)
) dut (
    .clk       (),
    .rstn      (),
    .en        (),
    .serial_in (),
    .dir       (),
    .q         ()
);
```

## Example

With:

```text
q         = 10110010
serial_in = 1
dir       = 0
```

After one enabled clock:

```text
q = 11011001
```

## Notes

* Reset asynchronously clears `q` to zero.
* When `en = 0`, the register holds its current value.
* `dir = 0` shifts right; `dir = 1` shifts left.
* `WIDTH` must be at least 2 because the implementation uses `WIDTH-2:0` and `WIDTH-1:1`.
