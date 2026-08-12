# RTL Design Library

A collection of reusable **SystemVerilog RTL designs**, developed as a personal hardware design library and practice repository.

The repository focuses on simple, synthesizable RTL blocks commonly used in digital design, FPGA development, and hardware engineering.

---

## Progress

<!-- PROGRESS:START -->

**Overall Progress: 67%**

`█████████████░░░░░░░` 67%

**Total: 2 / 3 completed**

### Category Progress

- **Combinational: 0%** (0/0)
- **Sequential: 0%** (0/0)
- **Control: 0%** (0/0)
- **Memory: 0%** (0/0)
- **CDC: 0%** (0/0)
- **Interfaces: 67%** (2/3)

### Module Progress

#### Combinational

- **MUX: 0%** (0/0)
- **Decoder: 0%** (0/0)
- **Encoder: 0%** (0/0)
- **Priority Encoder: 0%** (0/0)
- **Comparator: 0%** (0/0)
- **Full Adder: 0%** (0/0)
- **Ripple Carry Adder: 0%** (0/0)
- **Barrel Shifter: 0%** (0/0)
- **ALU: 0%** (0/0)

#### Sequential

- **D Flip-Flop: 0%** (0/0)
- **Register: 0%** (0/0)
- **Counter: 0%** (0/0)
- **Shift Register: 0%** (0/0)

#### Control

- **FSM: 0%** (0/0)
- **Sequence Detector: 0%** (0/0)
- **Arbiter: 0%** (0/0)

#### Memory

- **Single-Port RAM: 0%** (0/0)
- **FIFO: 0%** (0/0)
- **FWFT FIFO: 0%** (0/0)
- **Async FIFO: 0%** (0/0)

#### CDC

- **2FF Synchronizer: 0%** (0/0)
- **Pulse Synchronizer: 0%** (0/0)
- **Handshake Synchronizer: 0%** (0/0)

#### Interfaces

- **UART TX: 0%** (0/0)
- **UART RX: 0%** (0/0)
- **SPI: 0%** (0/0)
- **I2C: 0%** (0/0)
- **FIFO: 67%** (2/3)

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

## Combinational

### MUX

* [X] RTL
* [X] Testbench
* [X] README

### Decoder

* [X] RTL
* [X] Testbench
* [X] README

### Encoder

* [ ] RTL
* [ ] Testbench
* [ ] README

### Priority Encoder

* [ ] RTL
* [ ] Testbench
* [ ] README

### Comparator

* [ ] RTL
* [ ] Testbench
* [ ] README

### Full Adder

* [X] RTL
* [X] Testbench
* [X] README

### Ripple Carry Adder

* [ ] RTL
* [ ] Testbench
* [ ] README

### Barrel Shifter

* [ ] RTL
* [ ] Testbench
* [ ] README

### ALU

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Sequential

### D Flip-Flop

* [ ] RTL
* [ ] Testbench
* [ ] README

### Register

* [ ] RTL
* [ ] Testbench
* [ ] README

### Counter

* [ ] RTL
* [ ] Testbench
* [ ] README

### Shift Register

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Control

### FSM

* [ ] RTL
* [ ] Testbench
* [ ] README

### Sequence Detector

* [ ] RTL
* [ ] Testbench
* [ ] README

### Arbiter

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Memory

### Single-Port RAM

* [ ] RTL
* [ ] Testbench
* [ ] README

### FIFO

* [ ] RTL
* [ ] Testbench
* [ ] README

### FWFT FIFO

* [ ] RTL
* [ ] Testbench
* [ ] README

### Async FIFO

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## CDC

### 2FF Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

### Pulse Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

### Handshake Synchronizer

* [ ] RTL
* [ ] Testbench
* [ ] README

---

## Interfaces

### UART TX

* [ ] RTL
* [ ] Testbench
* [ ] README

### UART RX

* [ ] RTL
* [ ] Testbench
* [ ] README

### SPI

* [ ] RTL
* [ ] Testbench
* [ ] README

### I2C

* [ ] RTL
* [ ] Testbench
* [ ] README

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
