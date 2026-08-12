## Run Simulation

```bash
iverilog -g2012 -o sim *.sv
```

- `-g2012` enables SystemVerilog-2012 support.
- `-o sim` names the output executable.

```bash
vvp sim
```

- Creates `wave.vcd` (if the testbench includes `$dumpfile` and `$dumpvars`).

---

## Run Yosys

Enter the Yosys shell.

```bash
yosys
```

Then

```bash
read_verilog -sv and_gate.sv
```

```bash
synth
```

```bash
stat
```

```bash
exit
```

**Or run everything in one command:**

```bash
yosys -p "read_verilog -sv and_gate.sv; synth; stat"
```

---

## Generate a Schematic

Behavioral logic (before mapping)

```bash
yosys -p "read_verilog -sv and_gate.sv; proc; opt; show -format dot -prefix schematic"
```

Synthesized gate-level netlist

```bash
yosys -p "read_verilog -sv and_gate.sv; synth; show -format dot -prefix schematic"
```

```bash
yosys -p "read_verilog -sv full_adder.sv adder4.sv; synth -top adder4; show -format dot -prefix schematic"
```


Creates `schematic.dot`.

Convert it to PDF:

```bash
dot -Tpdf schematic.dot -o schematic.pdf
```

Or PNG:

```bash
dot -Tpng schematic.dot -o schematic.png
```

---

## Save the Synthesized Netlist

```bash
yosys -p "read_verilog -sv and_gate.sv; synth; write_verilog synthesized.v"
```

---

## Save the Yosys Report

```bash
yosys -p "read_verilog -sv and_gate.sv; synth; stat" > yosys_report.txt
```

Only stat

```bash
yosys -p "read_verilog -sv and_gate.sv; synth; tee -o yosys_stat.txt stat"
```

!!! OpenRoad\OpenLane 2


python3 progress.py