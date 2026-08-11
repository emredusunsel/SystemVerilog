# Full Adder Module (`full_adder`)

## Overview
A combinational **1-bit Full Adder** written in SystemVerilog. It performs standard binary addition on two single-bit data inputs (`a`, `b`) along with an incoming carry bit (`cin`), producing a 1-bit sum (`s`) and a carry-out (`cout`).

---

## Port Description

| Port Name | Direction | Description |
| :--- | :--- | :--- |
| `a` | Input | First 1-bit operand input |
| `b` | Input | Second 1-bit operand input |
| `cin` | Input | Carry-in bit from previous stage |
| `s` | Output | Sum output bit |
| `cout` | Output | Carry-out output bit |

---

## Logic Equations

The combinational logic is implemented using continuous assignment (`assign`) statements:

- **Sum Bit ($S$):**  
  $$S = a \oplus b \oplus c_{in}$$

- **Carry-Out Bit ($C_{out}$):**  
  $$C_{out} = (c_{in} \cdot (a \oplus b)) + (a \cdot b)$$

---

## Truth Table

| `a` | `b` | `cin` | `cout` | `s` |
| :---: | :---: | :---: | :---: | :---: |
| 0 | 0 | 0 | **0** | **0** |
| 0 | 0 | 1 | **0** | **1** |
| 0 | 1 | 0 | **0** | **1** |
| 0 | 1 | 1 | **1** | **0** |
| 1 | 0 | 0 | **0** | **1** |
| 1 | 0 | 1 | **1** | **0** |
| 1 | 1 | 0 | **1** | **0** |
| 1 | 1 | 1 | **1** | **1** |

