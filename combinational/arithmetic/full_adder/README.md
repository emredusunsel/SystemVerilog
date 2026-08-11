# Full Adder Module (`full_adder`)

## Overview
A lightweight, combinational **1-bit Full Adder** written in SystemVerilog. It performs standard binary addition on two single-bit data inputs (`a`, `b`) along with an incoming carry bit (`cin`), producing a 1-bit sum (`s`) and a carry-out (`cout`).

---

## Port Description

| Port Name | Direction | Data Type | Description |
| :--- | :--- | :--- | :--- |
| `a` | Input | `logic` | First 1-bit operand input |
| `b` | Input | `logic` | Second 1-bit operand input |
| `cin` | Input | `logic` | Carry-in bit from previous stage |
| `s` | Output | `logic` | Sum output bit |
| `cout` | Output | `logic` | Carry-out output bit |

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

---

## Example Instantiation

```systemverilog
full_adder u_full_adder (
    .a    (a_in),
    .b    (b_in),
    .cin  (carry_in),
    .s    (sum_out),
    .cout (carry_out)
);