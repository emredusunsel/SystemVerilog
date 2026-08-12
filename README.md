# RTL Design Library

A collection of reusable **SystemVerilog RTL designs**, developed as a personal hardware design library and practice repository.

The repository focuses on simple, synthesizable RTL blocks commonly used in digital design, FPGA development, and hardware engineering.

---

## Progress

<!-- PROGRESS:START -->

**Overall Progress: 67%**

`█████████████░░░░░░░` 67%

**Total: 54 / 81 completed**

### Category Progress

- **CDC: 0%** (0/9)
- **Combinational: 88%** (21/24)
- **Control: 100%** (9/9)
- **Edge Detection: 100%** (3/3)
- **Interfaces: 20%** (3/15)
- **Memory: 67%** (6/9)
- **Sequential: 100%** (12/12)

### Module Progress

#### CDC

- **Pulse Synchronizer: 0%** (0/3)
- **2FF Synchronizer: 0%** (0/3)
- **Handshake Synchronizer: 0%** (0/3)

#### Combinational

- **ALU: 0%** (0/3)
- **Full Adder: 100%** (3/3)
- **RCA: 100%** (3/3)
- **Barrel Shifter: 100%** (3/3)
- **Comparator: 100%** (3/3)
- **Decoder: 100%** (3/3)
- **Encoder: 100%** (3/3)
- **MUX: 100%** (3/3)

#### Control

- **Arbiter: 100%** (3/3)
- **FSM: 100%** (3/3)
- **Sequence Detector: 100%** (3/3)

#### Edge Detection

- **Synchronous Edge Detector: 100%** (3/3)

#### Interfaces

- **UART: 33%** (3/9)
- **SPI: 0%** (0/3)
- **I2C: 0%** (0/3)

#### Memory

- **FIFO: 100%** (3/3)
- **Single-Port RAM: 100%** (3/3)
- **Async FIFO: 0%** (0/3)

#### Sequential

- **Counter: 100%** (3/3)
- **D Flip-Flop: 100%** (3/3)
- **Register: 100%** (3/3)
- **Shift Register: 100%** (3/3)

<!-- PROGRESS:END -->

Progress is automatically calculated from [`PROGRESS.md`](PROGRESS.md).
Run pthon3 progress.py

---

## Repository Structure

```text
.
├── combinational/
│   ├── arithmetic/
│   ├── barrel_shifter/
│   ├── comparator/
│   ├── decoder/
│   ├── encoder/
│   └── mux/
│
├── sequential/
│   ├── counter/
│   ├── dff/
│   ├── register/
│   └── shift_register/
│
├── control/
│   ├── arbiter/
│   ├── fsm/
│   └── sequence_detector/
│
├── memory/
│   ├── fifo/
│   ├── fwft_fifo/
│   ├── async_fifo/
│   └── ram/
│
├── cdc/
│   ├── 2ff_synchronizer/
│   ├── pulse_synchronizer/
│   └── handshake_synchronizer/
│
├── interfaces/
│   ├── uart/
│   ├── spi/
│   └── i2c/
│
├── progress.py
└── .github/
    └── workflows/
        └── update-progress.yml
```

---

# Module Structure

Each completed module should contain its RTL, testbench, and documentation.

Example:

```text
fifo/
├── fifo.sv
├── tb/
│   └── fifo_tb.sv
└── README.md
```

The exact structure may vary depending on the module.

---

# Design Principles

The designs in this repository aim to follow these principles:

* Synthesizable SystemVerilog
* Simple and readable RTL
* Parameterized designs where useful
* Clear module interfaces
* Explicit reset behavior
* Synchronous design practices
* Reusable modules
* Separate RTL and verification code
* Avoid unnecessary complexity

The goal is to build a **compact and practical RTL library**, rather than an exhaustive collection of every possible hardware design.

