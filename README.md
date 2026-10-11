# RTL Design Library

A collection of reusable **SystemVerilog RTL designs**, developed as a personal hardware design library and practice repository.

The repository focuses on simple, synthesizable RTL blocks commonly used in digital design, FPGA development, and hardware engineering.

---

# PY SCRIPTS

Verilator simulation:

```bash
python3 scripts/run.py dff
```

Coverage report (local):

```bash
python3 scripts/report_coverage.py dff
```

---

### TASK: Re-write Testbenchs

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
