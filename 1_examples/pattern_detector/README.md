# Pattern Detector

## Overview

A **finite state machine (FSM) based pattern detector** that detects the bit pattern `110101` on a serial input.

When the complete pattern is detected, `out` is asserted for one clock cycle.

## Features

* Detects the `110101` pattern
* FSM-based implementation
* Active-low asynchronous reset
* Supports overlapping pattern detection
* Fully synthesizable

## Interface

| Signal | Direction | Description                    |
| ------ | --------- | ------------------------------ |
| `clk`  | Input     | Clock                          |
| `rstn` | Input     | Active-low asynchronous reset  |
| `in`   | Input     | Serial input bit               |
| `out`  | Output    | High when `110101` is detected |

## Functionality

The FSM tracks the progress of the input sequence:

```text id="q7f3fz"
1 → 11 → 110 → 1101 → 11010 → 110101
```

When the FSM reaches `S110101`, the pattern has been detected and:

```text
out = 1
```

The output is otherwise `0`.

### Example

For the input stream:

```text
... 1 1 0 1 0 1 ...
    └──────────┘
       110101
```

`out` becomes high when the final `1` of the pattern is received.

## State Description

| State     | Matched Pattern |
| --------- | --------------- |
| `IDLE`    | Nothing         |
| `S1`      | `1`             |
| `S11`     | `11`            |
| `S110`    | `110`           |
| `S1101`   | `1101`          |
| `S11010`  | `11010`         |
| `S110101` | `110101`        |

The FSM also handles overlapping sequences. For example, after detecting `110101`, the state can transition to `S11` when the next input is `1`, allowing another pattern to begin without resetting the entire detector.

## Implementation

The design uses three main parts:

1. **State register** — stores the current FSM state.
2. **Next-state logic** — determines the next state from the current state and input.
3. **Output logic** — asserts `out` when the FSM is in `S110101`.

The state register uses an active-low asynchronous reset and returns to `IDLE` when `rstn` is deasserted.

## Example

```systemverilog id="c5d3x8"
logic clk;
logic rstn;
logic in;
logic out;

pattern_detector dut (
    .clk  (clk),
    .rstn (rstn),
    .in   (in),
    .out  (out)
);
```

## Notes

* The detected pattern is `110101`.
* One input bit is processed on each rising clock edge.
* `out` is asserted while the FSM is in the final matching state.
* The design supports overlapping patterns.
* No counter or shift register is required; detection is performed entirely using the FSM.
