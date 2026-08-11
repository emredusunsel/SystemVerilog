# Parameterized Register

## Overview

A parameterized **N-bit register** with an enable input and an active-low asynchronous reset.

The register captures `in` on the rising edge of `clk` when `en` is asserted.

## Features

* Parameterized data width
* Configurable reset value
* Enable control
* Active-low asynchronous reset
* Positive-edge triggered
* Fully synthesizable

## Parameters

| Parameter     | Default | Description                          |
| ------------- | ------: | ------------------------------------ |
| `WIDTH`       |       8 | Width of the register                |
| `RESET_VALUE` |    `'0` | Value loaded into `out` during reset |

## Interface

| Signal | Direction |   Width | Description                   |
| ------ | --------- | ------: | ----------------------------- |
| `clk`  | Input     |       1 | Clock                         |
| `rstn` | Input     |       1 | Active-low asynchronous reset |
| `en`   | Input     |       1 | Enable for loading new data   |
| `in`   | Input     | `WIDTH` | Input data                    |
| `out`  | Output    | `WIDTH` | Registered output             |

## Functionality

| Condition              | `out`                |
| ---------------------- | -------------------- |
| `rstn = 0`             | `RESET_VALUE`        |
| Rising `clk`, `en = 1` | Loads `in`           |
| Rising `clk`, `en = 0` | Holds previous value |

The reset has priority over the enable.

## Example Instantiation

```systemverilog
register #(
    .WIDTH      (16),
    .RESET_VALUE(16'h1234)
) dut (
    .clk  (),
    .rstn (),
    .en   (),
    .in   (),
    .out  ()
);
```

## Notes

* The register is updated only on the rising edge of `clk`.
* Reset is asynchronous and active-low.
* When `en` is low, the previous value is retained.
* `RESET_VALUE` allows the reset state to be customized.
* The design can be used as a basic building block for wider datapaths and control logic.
