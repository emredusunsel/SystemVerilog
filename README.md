# RTL Design Library

A collection of reusable **SystemVerilog RTL designs**, developed as a personal hardware design library and practice repository.

The repository focuses on simple, synthesizable RTL blocks commonly used in digital design, FPGA development, and hardware engineering.

---

## Progress

<!-- PROGRESS:START -->

**Overall Progress: 79%**

`████████████████░░░░` 79%

**Total: 69 / 87 completed**

### Category Progress

- **CDC: 25%** (3/12)
- **Combinational: 100%** (24/24)
- **Control: 100%** (9/9)
- **Edge Detection: 100%** (3/3)
- **Interfaces: 60%** (9/15)
- **Memory: 75%** (9/12)
- **Sequential: 100%** (12/12)

### Module Progress

#### CDC

- **Async FIFO: 100%** (3/3)
- **Handshake Synchronizer: 0%** (0/3)
- **Pulse Synchronizer: 0%** (0/3)
- **2FF Synchronizer: 0%** (0/3)

#### Combinational

- **ALU: 100%** (3/3)
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

- **UART: 100%** (9/9)
- **SPI: 0%** (0/3)
- **I2C: 0%** (0/3)

#### Memory

- **FIFO: 100%** (3/3)
- **FWFT FIFO: 100%** (3/3)
- **Dual-Port RAM: 0%** (0/3)
- **Single-Port RAM: 100%** (3/3)

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
├── 0_docs/
│   └── ...
│
├── 1_examples/
│   └── pattern_detector/
│
├── cdc/
│   ├── async_fifo/
│   ├── handshake_sync/
│   └── pulse_sync/
│   └── sync_2ff/
│
├── combinational/
│   ├── arithmetic/
│   │   ├── alu/
│   │   ├── full_adder/
│   │   └── rca/
│   │
│   ├── barrel_shifter/
│   ├── comparator/
│   ├── decoder/
│   ├── encoder/
│   └── mux/
│
├── control/
│   ├── arbiter/
│   ├── fsm/
│   └── sequence_detector/
│
├── edge_detection/
│   └── sync_det/
│
├── interfaces/
│   ├── i2c/
│   ├── spi/
│   └── uart/
│       ├── rx/
│       ├── tx/
│       └── uart/
│
├── memory/
│   ├── fifo/
│   │   ├── fifo/
│   │   └── fwft_fifo/
│   └── ram/
│       ├── dual_port_ram/
│       └── single_port_ram/
│
├── sequential/
│   ├── counter/
│   ├── flip_flop/
│   ├── register/
│   └── shift_register/
│
└── README.md
```

---

# Module Structure

Each completed module should contain its RTL, testbench, and documentation.

Example:

```text
fifo/
├── fifo.sv
├── fifo_tb.sv/
└── README.md
```

The exact structure may vary depending on the module.

---

# Design Principles

The designs in this repository aim to follow these principles:

* Synthesizable SystemVerilog
* Simple and readable RTL
* Parameterized designs where useful
* Reusable modules
* Separate RTL and verification code
* Avoid unnecessary complexity

The goal is to build a **compact and practical RTL library**, rather than an exhaustive collection of every possible hardware design.
