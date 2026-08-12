# Parameterized Sequence Detector

## Overview

A parameterized **sequence detector** that detects a predefined bit pattern in a serial input stream.

The module stores the most recent `SEQ_LEN` input bits in a shift register and asserts `out` when they match the configured `PATTERN`.

## Features

* Parameterized sequence length
* Configurable detection pattern
* Serial input
* Active-low asynchronous reset
* Shift-register based implementation
* Supports overlapping sequences

## Parameters

| Parameter |   Default | Description                    |
| --------- | --------: | ------------------------------ |
| `SEQ_LEN` |         4 | Number of bits in the sequence |
| `PATTERN` | `4'b1011` | Bit pattern to detect          |

## Interface

| Signal | Direction | Width | Description                                     |
| ------ | --------- | ----: | ----------------------------------------------- |
| `clk`  | Input     |     1 | Clock                                           |
| `rstn` | Input     |     1 | Active-low asynchronous reset                   |
| `in`   | Input     |     1 | Serial input bit                                |
| `out`  | Output    |     1 | High when the stored sequence matches `PATTERN` |

## Functionality

On every rising edge of `clk`, the input bit is shifted into `seq_mem`:

```text
seq_mem <= {seq_mem[SEQ_LEN-2:0], in};
```

The oldest bit is removed and the newest bit is inserted at the LSB.

The output is asserted when the stored sequence matches the configured pattern:

```text
out = (seq_mem == PATTERN)
```

### Example

With:

```text
SEQ_LEN = 4
PATTERN = 1011
```

For an input stream:

```text
1 → 0 → 1 → 1
```

After the fourth bit:

```text
seq_mem = 1011
out     = 1
```

If the next input bit is `0`:

```text
seq_mem = 0110
out     = 0
```

## Implementation

The design consists of:

* **Shift register (`seq_mem`)** — stores the most recent input bits.
* **Pattern comparison** — continuously compares `seq_mem` with `PATTERN`.

Because the comparison is continuous, `out` becomes high whenever the current window of `SEQ_LEN` bits matches the target pattern.

## Example Instantiation

```systemverilog
sequence_detector #(
    .SEQ_LEN (4),
    .PATTERN (4'b1011)
) dut (
    .clk  (clk),
    .rstn (rstn),
    .in   (in),
    .out  (out)
);
```

## Notes

* The detector operates on a **sliding window** of the most recent `SEQ_LEN` bits.
* The pattern can be changed through the `PATTERN` parameter.
* Overlapping occurrences are naturally supported.
* The design is synchronous, with an active-low asynchronous reset.
* `SEQ_LEN` should be at least 2 because of the shift-register indexing.
