# LIFO Stack

## Overview

A parameterized **Last-In, First-Out (LIFO) stack**.

The most recently pushed data is the first data returned by a pop operation.

The stack supports push, pop, and simultaneous push/pop operations.

## Features

- Parameterized data width, stack depth
- Simultaneous push/pop support
- `empty` and `full` status flags
- Stack element count output
- Active-low reset
- Parameter validation
- Power-of-two depth requirement

## Parameters

| Parameter | Default | Description                      |
|-----------|--------:|----------------------------------|
| `WIDTH`   | 8       | Number of bits per stack element |
| `DEPTH`   | 16      | Maximum number of elements       |

The current implementation requires:

- `WIDTH >= 1`
- `DEPTH >= 2`
- `DEPTH` must be a power of two

## Interface

| Signal      | Direction | Width             | Description                              |
|-------------|-----------|------------------:|------------------------------------------|
| `clk`       | Input     | 1                 | Clock                                    |
| `rstn`      | Input     | 1                 | Active-low reset                         |
| `push`      | Input     | 1                 | Enables a push operation                 |
| `push_data` | Input     | `WIDTH`           | Data to push onto the stack              |
| `pop`       | Input     | 1                 | Enables a pop operation                  |
| `pop_data`  | Output    | `WIDTH`           | Data removed from the stack              |
| `empty`     | Output    | 1                 | High when the stack contains no elements |
| `full`      | Output    | 1                 | High when the stack is full              |
| `count`     | Output    | `$clog2(DEPTH)+1` | Current number of stored elements        |

## Operation

The stack stores data in an internal memory and uses a stack pointer to track the next available stack location.

Data follows **Last-In, First-Out** ordering.

For example:

```text
Push A
Push B
Push C

Pop -> C
Pop -> B
Pop -> A
```

## Push Operation

When `push` is asserted and the stack is not full:

```text
push = 1
full = 0
```

`push_data` is written to the current stack location and the stack pointer is incremented.

```text
mem[stack_ptr] = push_data
stack_ptr      = stack_ptr + 1
```

## Pop Operation

When `pop` is asserted and the stack is not empty:

```text
pop = 1
empty = 0
```

The top stack element is returned through `pop_data` and the stack pointer is decremented.

The previously occupied memory location is also cleared.

```text
pop_data  = mem[stack_ptr - 1]
stack_ptr = stack_ptr - 1
```

## Simultaneous Push and Pop

The module explicitly handles simultaneous `push` and `pop`.

### Non-Empty, Non-Full

When both operations are requested and the stack is neither empty nor full:

```text
push = 1
pop  = 1
empty = 0
full  = 0
```

The current top element is returned through `pop_data`, while `push_data` replaces it.

The stack depth remains unchanged.

### Empty

When the stack is empty and both `push` and `pop` are asserted:

```text
empty = 1
push = 1
pop  = 1
```

The push operation is accepted and the stack pointer is incremented.

The new element is stored in the stack.

### Full

When the stack is full and both `push` and `pop` are asserted:

```text
full = 1
push = 1
pop  = 1
```

The top element is returned through `pop_data` and replaced by `push_data`.

The stack remains full.

## Operation Table

| `pop` | `push` | Condition           | Operation                         |
|:-----:|:------:|---------------------|-----------------------------------|
| 0     | 0      | Any                 | No operation                      |
| 0     | 1      | `full = 0`          | Push                              |
| 0     | 1      | `full = 1`          | No operation                      |
| 1     | 0      | `empty = 0`         | Pop                               |
| 1     | 0      | `empty = 1`         | No operation                      |
| 1     | 1      | Non-empty, non-full | Pop top and replace with new data |
| 1     | 1      | Empty               | Push new data                     |
| 1     | 1      | Full                | Pop top and replace with new data |

## Stack Pointer

The internal `stack_ptr` tracks the number of elements currently stored in the stack.

It points to the next available location for a push.

For example, with `DEPTH = 4`:

```text
stack_ptr = 0  -> empty
stack_ptr = 1  -> 1 element
stack_ptr = 2  -> 2 elements
stack_ptr = 3  -> 3 elements
stack_ptr = 4  -> full
```

The output `count` is directly assigned from `stack_ptr`.

```text
count = stack_ptr
```

## Status Flags

### Empty

`empty` is asserted when the stack contains zero elements.

```text
empty = (stack_ptr == 0)
```

### Full

`full` is asserted when the stack contains `DEPTH` elements.

```text
full = (stack_ptr == DEPTH)
```

### Count

`count` represents the current number of elements stored in the stack.

```text
count = stack_ptr
```

The count can therefore range from:

```text
0 -> DEPTH
```

## Reset

The reset is active-low.

When `rstn` is low on a clock edge:

```text
stack_ptr = 0
pop_data  = 0
```

This makes the stack empty.

The internal memory contents are not reset.

## Memory Structure

The stack uses an internal memory array:

```text
logic [WIDTH-1:0] mem [DEPTH];
```

With the default configuration:

```text
WIDTH = 8
DEPTH = 16
```

the stack stores up to 16 elements, with each element being 8 bits wide.

## Parameter Validation

The module checks the supported parameter ranges during elaboration.

`WIDTH` must be at least 1:

```text
WIDTH >= 1
```

`DEPTH` must be at least 2 and a power of two:

```text
DEPTH >= 2
DEPTH = power of two
```

Invalid configurations terminate simulation with `$fatal`.

## Example

```systemverilog
logic       clk;
logic       rstn;

logic       push;
logic [7:0] push_data;

logic       pop;
logic [7:0] pop_data;

logic       empty;
logic       full;
logic [4:0] count;

lifo #(
    .WIDTH (8),
    .DEPTH (16)
) dut (
    .clk       (clk),
    .rstn      (rstn),
    .push      (push),
    .push_data (push_data),
    .pop       (pop),
    .pop_data  (pop_data),
    .empty     (empty),
    .full      (full),
    .count     (count)
);
```

## Example Sequence

Starting from an empty stack:

```text
count = 0
empty = 1
full  = 0
```

Push `A`:

```text
push_data = A
push      = 1

count = 1
empty = 0
```

Push `B`:

```text
push_data = B
push      = 1

count = 2
```

Push `C`:

```text
push_data = C
push      = 1

count = 3
```

Pop:

```text
pop = 1

pop_data = C
count    = 2
```

Pop again:

```text
pop = 1

pop_data = B
count    = 1
```

The remaining element is `A`.

## Notes

- The stack follows Last-In, First-Out ordering.
- `push` is ignored when the stack is full unless `pop` is also asserted.
- `pop` is ignored when the stack is empty unless `push` is also asserted.
- Simultaneous push/pop keeps the stack depth unchanged when the stack is neither empty nor full.
- Simultaneous push/pop on a full stack replaces the top element.
- Simultaneous push/pop on an empty stack performs a push.
- `count` represents the current number of stored elements.
- The memory contents are not reset.
- `pop_data` is reset to zero.
- `DEPTH` must be a power of two.
