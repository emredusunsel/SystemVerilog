# Parameterized Multiplexer

## Overview

A parameterized **multiplexer (MUX)** that selects one input from multiple `WIDTH`-bit input vectors using the `sel` signal.

The number of inputs is configurable through the `INPUTS` parameter.

## Features

* Parameterized data width
* Parameterized number of inputs
* Combinational implementation
* Direct array indexing for selection
* Fully synthesizable

## Parameters

| Parameter |    Default | Description                    |
| --------- | ---------: | ------------------------------ |
| `WIDTH`   |          4 | Width of each input and output |
| `INPUTS`  | `2**WIDTH` | Number of input vectors        |

## Interface

|    Signal    | Direction |            Width | Description                            |
| ------------ | --------- | ---------------: | -------------------------------------- |
| `in[INPUTS]` | Input     |          `WIDTH` | Array of input vectors                 |
| `sel`        | Input     | `$clog2(INPUTS)` | Selects which input is passed to `out` |
| `out`        | Output    |          `WIDTH` | Selected input                         |

## Functionality

The multiplexer selects one input based on `sel`:

```text
out = in[sel]
```

For example, with `WIDTH = 4` and `INPUTS = 4`:

| `sel` | `out`   |
| ----- | ------- |
| `00`  | `in[0]` |
| `01`  | `in[1]` |
| `10`  | `in[2]` |
| `11`  | `in[3]` |

## Implementation

The design uses a SystemVerilog unpacked array for the inputs:

```text
in[0]
in[1]
in[2]
...
in[INPUTS-1]
```

The selected element is directly assigned to the output using:

```systemverilog
assign out = in[sel];
```

This allows the synthesizer to implement the required multiplexer logic.

## Example Instantiation

```systemverilog
mux #(
    .WIDTH  (8),
    .INPUTS (4)
) dut (
    .in  (),
    .sel (),
    .out ()
);
```

## Notes

* The module is purely combinational.
* No clock or reset is required.
* `sel` determines which input is routed to the output.
* `INPUTS` should be chosen so that `$clog2(INPUTS)` provides enough select bits.
