# LFSR

## Overview

A parameterized **Linear Feedback Shift Register (LFSR)** with seed loading, sequence completion detection, and zero-state lock detection.

The module advances the LFSR when `enable` is asserted and can load a new seed through `seed_valid`.

It also tracks the loaded seed so that it can detect when the LFSR returns to its starting state.

## Features

- Parameterized LFSR width and feedback polynomial
- Configurable seed loading
- Enable-controlled LFSR advancement
- Internal FSM with `IDLE`, `RUN`, `DONE`, and `LOCKED` states

## Parameters

| Parameter    | Default   | Description              |
|--------------|----------:|--------------------------|
| `WIDTH`      | 4         | Width of the LFSR        |
| `POLYNOMIAL` | `4'b1100` | Feedback polynomial mask |

The polynomial width should match `WIDTH`.

## Interface

| Signal          | Direction | Width   | Description                                             |
|-----------------|-----------|--------:|---------------------------------------------------------|
| `clk`           | Input     | 1       | Clock                                                   |
| `rstn`          | Input     | 1       | Active-low reset                                        |
| `enable`        | Input     | 1       | Advances the LFSR when asserted                         |
| `seed_valid`    | Input     | 1       | Requests loading of a new seed                          |
| `seed`          | Input     | `WIDTH` | New seed value                                          |
| `clear`         | Input     | 1       | Returns the LFSR to its initial state                   |
| `lfsr_data`     | Output    | `WIDTH` | Current LFSR state                                      |
| `valid`         | Output    | 1       | Indicates that the LFSR contains a valid non-zero state |
| `locked`        | Output    | 1       | Indicates that the LFSR entered the zero state          |
| `sequence_done` | Output    | 1       | Indicates that the LFSR returned to its loaded seed     |

## LFSR Operation

The LFSR shifts the current state and generates a new feedback bit using the configured polynomial.

The next state is calculated as:

```text
lfsr_next = {current[WIDTH-2:0], feedback}
```

The feedback bit is generated using the XOR reduction of the current LFSR state masked by `POLYNOMIAL`.

```text
feedback = ^(lfsr_current & POLYNOMIAL)
```

Therefore:

```text
lfsr_next = {lfsr_current[WIDTH-2:0],
             ^(lfsr_current & POLYNOMIAL)}
```

## Initial State

The initial LFSR state is generated as:

```text
INIT = 100...0
```

For example, with `WIDTH = 4`:

```text
INIT = 4'b1000
```

After reset or `clear`, the LFSR returns to this initial state.

## Seed Loading

A new seed can be loaded by asserting `seed_valid`.

When:

```text
seed_valid = 1
seed != 0
```

the provided `seed` becomes the current LFSR state and is also stored as the initial seed used for sequence completion detection.

A zero seed is not considered valid.

```text
seed = 0
```

causes the FSM to enter the `LOCKED` state.

## Enable

The LFSR advances when:

```text
enable = 1
```

and the FSM is operating in a state where advancement is allowed.

When `enable` is not asserted, the current LFSR state is held.

## Clear

When `clear` is asserted, the LFSR and stored initial seed return to the default `INIT` value.

The FSM also returns to `IDLE`.

The clear operation therefore provides a complete restart of the LFSR sequence.

## FSM

The design uses four states:

```text
IDLE
RUN
DONE
LOCKED
```

### IDLE

The LFSR contains a valid state but is not currently advancing.

From `IDLE`:

- `enable` starts the sequence
- `seed_valid` loads a new seed
- `clear` returns the design to the initial state
- A zero seed causes `LOCKED`

### RUN

The LFSR is actively advancing.

When `enable` is asserted, the next LFSR state is calculated.

The next state is checked for two special conditions:

```text
lfsr_next == 0
```

or:

```text
lfsr_next == seed_init
```

A zero next state causes `LOCKED`.

Returning to the loaded seed causes `DONE`.

### DONE

The LFSR has returned to its loaded seed.

`sequence_done` is asserted while the FSM is in this state.

The design can return to `RUN` if `enable` is asserted.

### LOCKED

The LFSR has entered the invalid zero state.

In this state:

```text
locked = 1
valid  = 0
```

The LFSR remains locked until either:

- `clear` is asserted
- a new non-zero seed is loaded

## Outputs

### `lfsr_data`

In `IDLE`, `RUN`, and `DONE`:

```text
lfsr_data = lfsr_current
```

In `LOCKED`:

```text
lfsr_data = 0
```

### `valid`

`valid` is asserted in:

```text
IDLE
RUN
DONE
```

It is deasserted in:

```text
LOCKED
```

### `locked`

`locked` is asserted only in the `LOCKED` state.

### `sequence_done`

`sequence_done` is asserted only in the `DONE` state.

## Output Table

| State    | `valid` | `locked` | `sequence_done` | `lfsr_data`        |
|----------|:-------:|:--------:|:---------------:|--------------------|
| `IDLE`   | 1       | 0        | 0               | Current LFSR state |
| `RUN`    | 1       | 0        | 0               | Current LFSR state |
| `DONE`   | 1       | 0        | 1               | Current LFSR state |
| `LOCKED` | 0       | 1        | 0               | `0`                |

## Sequence Completion

The module stores the loaded seed in `seed_init`.

During `RUN`, every new LFSR state is compared against this value.

When:

```text
lfsr_next == seed_init
```

the FSM transitions to `DONE`.

This allows the module to detect when the LFSR has completed its sequence and returned to its starting point.

## Lock Detection

An LFSR must not normally enter the all-zero state because an XOR-feedback LFSR can remain at zero indefinitely.

The module explicitly checks:

```text
lfsr_next == 0
```

If this occurs, the FSM enters `LOCKED`.

While locked:

```text
valid = 0
locked = 1
lfsr_data = 0
```

The module can recover by clearing it or loading a new non-zero seed.

## Reset

The design uses an active-low reset.

When `rstn` is low:

```text
state        = IDLE
lfsr_current = INIT
seed_init    = INIT
```

The outputs therefore indicate a valid initial LFSR state.

## Example

With:

```text
WIDTH      = 4
POLYNOMIAL = 4'b1100
```

the initial state is:

```text
INIT = 4'b1000
```

The LFSR then generates subsequent states according to:

```text
feedback = ^(lfsr_current & POLYNOMIAL)

lfsr_next = {lfsr_current[WIDTH-2:0], feedback}
```

The exact sequence depends on the selected polynomial and seed.

## Notes

- The LFSR uses XOR feedback and left shift.
- The polynomial acts as a feedback mask.
- A non-zero seed is required for normal operation.
- A zero seed causes the LFSR to enter `LOCKED`.
- `seed_init` stores the seed used to detect sequence completion.
- `sequence_done` is asserted when the LFSR returns to that stored seed.
- `clear` restores the default initial state.
- `enable` controls LFSR advancement.
- The polynomial should be selected appropriately for the desired sequence length.
