# Synchronized Edge Detector

## Overview

A clocked **edge detector** that synchronizes an input signal to `clk` and detects its rising and falling edges.

The module generates separate one-cycle pulses for positive and negative edges.

## Features

* Input synchronization using two flip-flops
* Rising-edge detection
* Falling-edge detection
* One-cycle edge pulses
* Fully synthesizable for FPGA flows that support register initialization

## Interface

| Signal   | Direction | Description                             |
| -------- | --------- | --------------------------------------- |
| `clk`    | Input     | Clock                                   |
| `signal` | Input     | Input signal to synchronize and monitor |
| `pe`     | Output    | Positive/rising-edge pulse              |
| `ne`     | Output    | Negative/falling-edge pulse             |

## Functionality

The input passes through two synchronization registers:

```text
signal → sync1 → sync2
```

A delayed copy of `sync2` is used to detect changes:

```text
sync2 ───────┐
             ├── Edge detection
delayed ─────┘
```

### Rising Edge

A rising edge is detected when:

```text
sync2 = 1
delayed_signal = 0
```

Therefore:

```text
pe = 1
```

### Falling Edge

A falling edge is detected when:

```text
sync2 = 0
delayed_signal = 1
```

Therefore:

```text
ne = 1
```

Both outputs are normally `0` and become high for one clock cycle when their corresponding edge is detected.

## Example Instantiation

```systemverilog
sync_det dut (
    .clk    (),
    .signal (),
    .pe     (),
    .ne     ()
);
```

## Notes

* The two flip-flops provide basic synchronization for an asynchronous input.
* Edge detection is performed on the synchronized signal, not directly on the input.
* `pe` and `ne` are combinational outputs based on registered signals.
* The module has no reset; the registers are initialized to `0` using an `initial` block.
* A change on `signal` is detected after passing through the synchronization pipeline.
