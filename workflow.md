
- Run on bash terminal

    - iverilog -g2012 -o sim and_gate.sv and_gate_tb.sv
    > -g2012 enables SystemVerilog-2012 support.
    > -o names the executable sim.

    - vvp sim
    > a file named wave.vcd will be created

    - yosys 
    > enter yosys shell

    - read_verilog -sv and_gate.sv

    - synth

    - stat

    - exit

OR

    - yosys -p "read_verilog -sv and_gate.sv; synth; stat"

- GENERATE SCHEMATIC

    ' yosys -p "read_verilog -sv and_gate.sv; proc; opt; show -format dot -prefix schematic" '

> this creates show.dot

convert it to pdf or png
    - dot -Tpdf show.dot -o schematic.pdf
    - dot -Tpng show.dot -o schematic.png

- SAVE THE SYNTHESIZED NETLIST 
    - yosys -p "read_verilog -sv counter.sv; synth; write_verilog synthesized.v"

- YOSYS REPORT

    - yosys -p "read_verilog -sv design.sv; synth; stat" > yosys_report.txt
