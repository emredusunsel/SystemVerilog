# FSM Controller

## Overview

A simple **finite state machine (FSM)** that controls an operation through four states: `IDLE`, `BUSY`, `DONE`, and `ERROR`.

The FSM uses synchronous state transitions with an **active-low asynchronous reset**.

## Features

* 4-state Moore FSM
* Active-low asynchronous reset
* Separate state, next-state, and output logic
* Handles start, completion, and error conditions
* Combinational output logic

## Interface

| Signal  | Direction | Description                                    |
| ------- | --------- | ---------------------------------------------- |
| `clk`   | Input     | System clock                                   |
| `rstn`  | Input     | Active-low asynchronous reset                  |
| `start` | Input     | Starts a new operation                         |
| `done`  | Input     | Indicates successful completion                |
| `error` | Input     | Indicates an error                             |
| `busy`  | Output    | High while the operation is running            |
| `valid` | Output    | High when the operation completes successfully |
| `fault` | Output    | High when an error occurs                      |

## States

| State   | Description                 | Output      |
| ------- | --------------------------- | ----------- |
| `IDLE`  | Waiting for a new operation | None        |
| `BUSY`  | Operation is in progress    | `busy = 1`  |
| `DONE`  | Operation completed         | `valid = 1` |
| `ERROR` | Operation failed            | `fault = 1` |

## State Transitions

```text
              start
        ┌───────────────┐
        │               ▼
      IDLE ──────────► BUSY
        ▲               │
        │          ┌────┴────┐
        │          │         │
        │        done      error
        │          │         │
        │          ▼         ▼
        │        DONE      ERROR
        │          │         │
        └──────────┴─────────┘
```

* `IDLE → BUSY` when `start` is asserted.
* `BUSY → ERROR` when `error` is asserted.
* `BUSY → DONE` when `done` is asserted and `error` is not asserted.
* `BUSY` remains active while neither `done` nor `error` is asserted.
* `DONE → IDLE` after one clock cycle.
* `ERROR → IDLE` after one clock cycle.

When both `done` and `error` are asserted in `BUSY`, **`error` has priority**.

## Implementation

The FSM is divided into three parts:

1. **State register** — stores the current state and resets to `IDLE`.
2. **Next-state logic** — determines the next state based on the current state and inputs.
3. **Output logic** — generates `busy`, `valid`, and `fault` based only on the current state.

Since the outputs depend only on the state, this is a **Moore FSM**.

## Example

```systemverilog
fsm dut (
    .clk   (clk),
    .rstn  (rstn),
    .start (start),
    .done  (done),
    .error (error),
    .busy  (busy),
    .valid (valid),
    .fault (fault)
);
```

## Notes

* `rstn` is active-low and asynchronously resets the FSM to `IDLE`.
* `busy`, `valid`, and `fault` are mutually exclusive.
* `DONE` and `ERROR` are one-cycle states before returning to `IDLE`.
* The FSM is fully synthesizable.
