# Arithmetic Logic Unit (ALU)

## Overview

A parameterized **ALU** that performs arithmetic, logical, shift, and comparison operations on two input operands.

The operation is selected using the `op` input. The ALU also provides status flags for zero, carry, overflow, and negative results.

## Features

* Parameterized data width
* Addition and subtraction
* Bitwise AND, OR, and XOR
* Logical and arithmetic shifts
* Signed and unsigned comparisons
* Zero, carry, overflow, and negative flags
* Combinational implementation
* Fully synthesizable

## Parameters

| Parameter | Default | Description                            |
| --------- | ------: | -------------------------------------- |
| `WIDTH`   |       8 | Width of the input operands and result |

## Interface

| Signal  | Direction |   Width | Description                     |
| ------- | --------- | ------: | ------------------------------- |
| `a`     | Input     | `WIDTH` | First operand                   |
| `b`     | Input     | `WIDTH` | Second operand                  |
| `op`    | Input     |       4 | Operation selection             |
| `out`   | Output    | `WIDTH` | Operation result                |
| `zero`  | Output    |       1 | High when `out` is zero         |
| `carry` | Output    |       1 | Carry from addition/subtraction |
| `of`    | Output    |       1 | Signed overflow flag            |
| `neg`   | Output    |       1 | High when result MSB is `1`     |

## Operations

| Operation | `op` | Description            |
| --------- | ---- | ---------------------- |
| `ADD_OP`  | `0`  | `a + b`                |
| `SUB_OP`  | `1`  | `a - b`                |
| `AND_OP`  | `2`  | `a & b`                |
| `OR_OP`   | `3`  | `a \| b`               |
| `XOR_OP`  | `4`  | `a ^ b`                |
| `SLL_OP`  | `5`  | Logical left shift     |
| `SRL_OP`  | `6`  | Logical right shift    |
| `SRA_OP`  | `7`  | Arithmetic right shift |
| `SLT_OP`  | `8`  | Signed less-than       |
| `SLTU_OP` | `9`  | Unsigned less-than     |

## Functionality

### Arithmetic

**Addition:**

```text
out = a + b
```

The `carry` flag contains the carry-out from the addition.

**Subtraction:**

```text
out = a - b
```

Subtraction is implemented using two's-complement arithmetic.

For both operations, `of` indicates signed arithmetic overflow.

### Logical Operations

The ALU supports bitwise:

```text
AND → a & b
OR  → a | b
XOR → a ^ b
```

### Shift Operations

The lower `$clog2(WIDTH)` bits of `b` are used as the shift amount.

```text
SLL → a << shamt
SRL → a >> shamt
SRA → signed(a) >>> shamt
```

`SRA_OP` preserves the sign bit during the right shift.

### Comparisons

`SLT_OP` performs a **signed** comparison:

```text
out = 1 when a < b
```

`SLTU_OP` performs an **unsigned** comparison:

```text
out = 1 when a < b
```

For both operations, the result is either `1` or `0`, represented as a `WIDTH`-bit value.

## Status Flags

| Flag    | Condition                      |
| ------- | ------------------------------ |
| `zero`  | `out == 0`                     |
| `carry` | Carry-out from ADD/SUB         |
| `of`    | Signed overflow during ADD/SUB |
| `neg`   | `out[WIDTH-1] == 1`            |

`zero` and `neg` are derived directly from the final ALU result.

## Example Instantiation

```systemverilog
logic [7:0] a;
logic [7:0] b;
logic [7:0] out;
logic zero, carry, of, neg;
alu_op_t op;

alu #(
    .WIDTH(8)
) dut (
    .a     (a),
    .b     (b),
    .op    (op),
    .out   (out),
    .zero  (zero),
    .carry (carry),
    .of    (of),
    .neg   (neg)
);
```

For example:

```text
a  = 8'b00000101
b  = 8'b00000011
op = ADD_OP

out = 8'b00001000
zero = 0
neg  = 0
```

## Implementation

The ALU uses a combinational `case` statement to select the requested operation.

A `WIDTH+1`-bit temporary value is used for addition and subtraction so that the carry-out can be captured separately from the result.

The shift amount is taken from the lower bits of `b`:

```text
shamt = b[$clog2(WIDTH)-1:0]
```

All outputs are combinational, so no clock or reset is required.

## Notes

* `ADD_OP` and `SUB_OP` generate the `carry` and `of` flags.
* Logical and comparison operations leave `carry` and `of` cleared.
* `neg` is based on the most significant bit of `out`.
* `SLT_OP` treats operands as signed.
* `SLTU_OP` treats operands as unsigned.
* The ALU is intended for combinational datapath use.
