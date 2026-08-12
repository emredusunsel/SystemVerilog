# RTL Design Library

A collection of reusable **SystemVerilog RTL designs**, developed as a personal hardware design library and practice repository.

The repository focuses on simple, synthesizable RTL blocks commonly used in digital design, FPGA development, and hardware engineering.

---

## Progress

<!-- PROGRESS:START -->

**Overall Progress: 49%**

`██████████░░░░░░░░░░` 49%

**Total: 40 / 81 completed**

### Category Progress

- **CDC: 0%** (0/9)
- **Combinational: 62%** (15/24)
- **Control: 67%** (6/9)
- **Edge Detection: 100%** (3/3)
- **Interfaces: 13%** (2/15)
- **Memory: 67%** (6/9)
- **Sequential: 67%** (8/12)

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
- **Comparator: 0%** (0/3)
- **Decoder: 100%** (3/3)
- **Encoder: 0%** (0/3)
- **MUX: 100%** (3/3)

#### Control

- **Arbiter: 100%** (3/3)
- **FSM: 100%** (3/3)
- **Sequence Detector: 0%** (0/3)

#### Edge Detection

- **Synchronous Edge Detector: 100%** (3/3)

#### Interfaces

- **UART: 22%** (2/9)
- **SPI: 0%** (0/3)
- **I2C: 0%** (0/3)

#### Memory

- **FIFO: 100%** (3/3)
- **Single-Port RAM: 100%** (3/3)
- **Async FIFO: 0%** (0/3)

#### Sequential

- **Counter: 0%** (0/3)
- **D Flip-Flop: 67%** (2/3)
- **Register: 100%** (3/3)
- **Shift Register: 100%** (3/3)

<!-- PROGRESS:END -->

Progress is calculated automatically from the checkboxes below.

* `[ ]` — Not completed
* `[x]` — Completed

For each module:

* **RTL** — Design is implemented
* **Testbench** — Verification is implemented
* **README** — Module documentation is completed

Do not manually edit the generated progress section.

---

# Modules

## CDC

### Pulse Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

### 2FF Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

### Handshake Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Combinational

### ALU

* [ ] RTL
* [ ] Testbench
* [ ] README

### Full Adder

* [X] RTL
* [X] Testbench
* [X] README

### RCA

* [X] RTL
* [X] Testbench
* [X] README

### Barrel Shifter

* [X] RTL
* [X] Testbench
* [X] README

### Comparator

* [ ] RTL
* [ ] Testbench
* [ ] README

### Decoder

* [X] RTL
* [X] Testbench
* [X] README

### Encoder

* [ ] RTL
* [ ] Testbench
* [ ] README

### MUX

* [X] RTL
* [X] Testbench
* [X] README

---

## Control

### Arbiter

* [X] RTL
* [X] Testbench
* [X] README

### FSM

* [X] RTL
* [X] Testbench
* [X] README

### Sequence Detector

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Edge Detection

### Synchronous Edge Detector

* [X] RTL
* [X] Testbench
* [X] README

---

## Interfaces

### UART

* [ ] TX_RTL
* [ ] TX_Testbench
* [ ] TX_README
* [X] RX_RTL
* [X] RX_Testbench
* [ ] RX_README
* [ ] TOP_RTL
* [ ] TOP_Testbench
* [ ] TOP_README

### SPI

* [ ] RTL
* [ ] Testbench
* [ ] README

### I2C

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Memory

### FIFO

* [X] RTL
* [X] Testbench
* [X] README

### Single-Port RAM

* [X] RTL
* [X] Testbench
* [X] README

### Async FIFO

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Sequential

### Counter

* [ ] RTL
* [ ] Testbench
* [ ] README

### D Flip-Flop

* [X] RTL
* [ ] Testbench
* [X] README

### Register

* [X] RTL
* [X] Testbench
* [X] README

### Shift Register

* [X] RTL
* [X] Testbench
* [X] README

---

# Repository Structure

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

# Verification

Each module is accompanied by a SystemVerilog testbench where appropriate.

Verification generally covers:

* Reset behavior
* Normal operation
* Boundary conditions
* Corner cases
* Parameter variations
* Expected outputs
* Error conditions where applicable
* Waveform inspection

Simulation tools used in this repository include:

* Icarus Verilog
* Verilator
* Vivado Simulator

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

---

# Tools

The repository is primarily developed and tested using:

* **SystemVerilog**
* **Icarus Verilog**
* **Verilator**
* **Yosys**
* **GTKWave**
* **Xilinx Vivado**

---

# Automatic Progress Tracking

Progress is calculated automatically by `progress.py`.

GitHub Actions runs the script whenever changes are pushed to the `main` branch.

The workflow is located at:

```text
.github/workflows/update-progress.yml
```

The process is:

```text
Change checkbox
      ↓
   git push
      ↓
GitHub Actions
      ↓
  progress.py
      ↓
README.md updated
      ↓
Automatic commit
```

For example:

```markdown
### FIFO

- [x] RTL
- [x] Testbench
- [ ] README
```

This results in:

```text
FIFO: 67% (2/3)
```

The FIFO percentage contributes automatically to:

* **Memory**
* **Overall Progress**

No percentage needs to be manually entered.

---

# License

This repository is intended primarily for educational, experimental, and portfolio purposes.
