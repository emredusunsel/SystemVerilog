# RTL Library

A collection of simple, reusable RTL/SystemVerilog designs.

## Progress

<!-- PROGRESS:START -->
**Overall Progress: 0%**

- Total: 0 / 0 completed
<!-- PROGRESS:END -->

## Modules

### Combinational

- [ ] AND gate
- [ ] OR gate
- [ ] XOR gate
- [ ] NOT gate
- [ ] MUX
- [X] Decoder
- [X] Encoder
- [X] Priority Encoder
- [ ] Comparator
- [ ] Full Adder
- [ ] Ripple Carry Adder
- [ ] Barrel Shifter
- [ ] ALU

### Sequential

- [ ] D Flip-Flop
- [ ] Register
- [ ] Counter
- [ ] Shift Register

### Memory

- [ ] Single-Port RAM
- [ ] FIFO
- [ ] FWFT FIFO
- [ ] Async FIFO

### Control

- [ ] FSM
- [ ] Sequence Detector
- [ ] Arbiter

### CDC

- [ ] 2FF Synchronizer
- [ ] Pulse Synchronizer
- [ ] Handshake Synchronizer

### Interfaces

- [ ] UART TX
- [ ] UART RX
- [ ] SPI
- [ ] I2C

## How Progress Works

The completion percentage is generated automatically from the checkboxes above.

- `[ ]` = not completed
- `[x]` = completed

Do **not** manually edit the percentage between `PROGRESS:START` and `PROGRESS:END`.

When a module is completed, simply change its checkbox:

```text
- [ ] FIFO
```

to:

```text
- [x] FIFO
```

A GitHub Actions workflow automatically runs `progress.py` and updates this section.
