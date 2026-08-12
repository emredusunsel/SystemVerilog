# Comparator

## Overview

A parameterized **comparator** that compares two unsigned `WIDTH`-bit values and indicates whether `a` is equal to, greater than, or less than `b`.

## Features

* Parameterized data width
* Equality comparison
* Greater-than comparison
* Less-than comparison
* Combinational implementation
* Fully synthesizable

## Parameters

| Parameter | Default | Description               |
| --------- | ------: | ------------------------- |
| `WIDTH`   |       8 | Width of the input values |

## Interface

| Signal | Direction |   Width | Description        |
| ------ | --------- | ------: | ------------------ |
| `a`    | Input     | `WIDTH` | First value        |
| `b`    | Input     | `WIDTH` | Second value       |
| `eq`   | Output    |       1 | High when `a == b` |
| `gt`   | Output    |       1 | High when `a > b`  |
| `lt`   | Output    |       1 | High when `a < b`  |

## Functionality

The three outputs indicate the relationship between `a` and `b`:

| Condition | `eq` | `gt` | `lt` |
| --------- | :--: | :--: | :--: |
| `a == b`  |   1  |   0  |   0  |
| `a > b`   |   0  |   1  |   0  |
| `a < b`   |   0  |   0  |   1  |

Only one output is asserted for a valid binary comparison.

## Implementation

The comparator uses SystemVerilog relational operators:

```systemverilog
assign eq = (a == b);
assign gt = (a > b);
assign lt = (a < b);
```

Since there is no clock or storage element, the outputs change combinationally with the inputs.

## Example Instantiation

```systemverilog
comparator #(
    .WIDTH(8)
) dut (
    .a  (a),
    .b  (b),
    .eq (eq),
    .gt (gt),
    .lt (lt)
);
```

## Notes

* The inputs are treated as unsigned `logic` vectors.
* `eq`, `gt`, and `lt` are mutually exclusive.
* The module is purely combinational.
* `WIDTH` can be changed to support different operand sizes.
