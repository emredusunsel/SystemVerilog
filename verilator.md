```bash
verilator -o ../sim -j 4 --binary --trace --assert --coverage-user \
--top-module fifo_tb fifo.sv fifo_tb.sv
```

```bash
./sim +verilator+quiet
```

```bash
./sim +verilator+coverage+file+coverage.dat
```

```bash
verilator_coverage --report summary,hier coverage.dat > coverage.txt
```

```bash
verilator_coverage --annotate coverage_details \
--annotate-all --annotate-points --annotate-min 1 \
coverage.dat
```


verilator --binary --timing --assert --coverage-user \
--top-module fifo_tb fifo.sv fifo_tb.sv

./obj_dir/Vfifo_tb +verilator+coverage+file+fifo_coverage.dat
./obj_dir/Vfifo_tb

verilator_coverage --report summary,hier fifo_coverage.dat > coveruser.txt


| Part | Meaning |
|------|---------|
| `verilator` | Runs Verilator. |
| `--binary` | Translates your SystemVerilog into C++ and compiles a runnable simulator. Generates the C++ simulation wrapper automatically. |
| `--timing` | Supports timing constructs such as `#5`, `@(posedge clk_i)`, and `wait`. Already implied by `--binary`, so explicitly including it is redundant but fine. |
| `--assert` | Enables assertion checking, including supported `assert property` statements. |
| `--coverage-user` | Enables user-defined coverage, such as supported covergroups and `cover property` statements. |
| `--top-module fifo_tb` | Selectes `module fifo_tb` as the root of the simulation hierarchy. This is a module name, not file name. |
| `fifo.sv fifo_tb.sv` | Source files to compile. |

| Option | Meaning |
|---|---|
| `--lint-only` | Checks the code without building a simulator. Use instead of `--binary`. |
| `-Wall` | Enables additional lint warnings. |
| `-Wno-fatal` | Allows compilation to continue despite warnings. Warnings remain visible; errors still stop compilation. |
| `-Wno-WIDTH` | Suppresses `WIDTH` warnings specifically. General form: `-Wno-<WARNING>`. |
| `--trace` | Enables VCD waveform support. |
| `--trace-fst` | Enables FST waveform support, typically producing smaller files than VCD. |
| `--coverage` | Enables all supported coverage types, including user coverage. |
| `--coverage-line` | Enables coverage of executed code blocks. |
| `--coverage-toggle` | Tracks signal bits changing between `0` and `1`. |
| `-j 4` | Uses up to four parallel build jobs to speed up compilation. |
| `--Mdir build` | Places generated files in `build` instead of `obj_dir`. |
| `-o sim` | Names the executable `sim`; by default, it goes inside `obj_dir`. |
| `-I./include` | Searches `./include` for files referenced by `` `include ``. |
| `-DDEBUG` | Defines the macro `DEBUG`, usable with `` `ifdef DEBUG ``. |
| `-GDEPTH=8` | Overrides parameter `DEPTH` **on the top module**. |
| `-f files.f` | Reads source filenames and options from `files.f`. |
| `--version` | Prints your installed Verilator version. |

| Part | Meaning |
|---|---|
| `./` | Start from the current directory. |
| `obj_dir/` | Folder containing the generated simulator. |
| `Vfifo_tb` | Executable built for your `fifo_tb` top module. |
| `+verilator+coverage+file+fifo_coverage.dat` | Runtime argument setting the coverage output file to `coverage.dat`. |

| Argument | Meaning |
|---|---|
| `+verilator+seed+31` | Sets the random seed to `31`, helping reproduce randomized runs. |
| `+verilator+error+limit+10` | Allows up to 10 nonfatal errors before stopping. Does **not** delay `$fatal`. |
| `+verilator+coverage+file+run31.dat` | Sets the coverage output filename. |
| `+verilator+noassert` | Disables assertion checking for that run. |
| `+verilator+quiet` | Hides Verilator’s simulation summary; your `$display` messages remain. |

| Part | Meaning |
|---|---|
| `verilator_coverage` | Runs Verilator’s coverage-processing tool. |
| `--report` | Requests a readable coverage report. |
| `summary` | Shows overall coverage totals grouped by coverage type. |
| `hier` | Shows coverage organized by the design hierarchy. Also written as `hierarchy`. |
| `summary,hier` | Requests both reports, separated by a comma without spaces. |
| `coverage.dat` | Input coverage data from your simulation. |

| Option | Meaning |
|---|---|
| `--levels 2` | Limits how deeply the hierarchy report expands. Deeper coverage still contributes to parent totals. |
| `--filter-type covergroup` | Reports only covergroup coverage. Other types include `user`, `line`, and `toggle`. |
| `--annotate cov_report` | Creates source-code copies with coverage counts inside `cov_report/`. |
| `--annotate-all` | Includes fully covered source files too. Use with `--annotate`. |
| `--annotate-points` | Shows individual coverage points beneath source lines. Use with `--annotate`. |
| `--annotate-min 1` | Sets the annotation coverage threshold to one hit. Default: 10. |
| `--write merged.dat` | Combines input coverage files into one `.dat` file, adding their counts. |
| `--write-info coverage.info` | Exports coverage in LCOV format for tools such as `genhtml`. |
| `--help` | Shows available options. |






`--DDEBUG` enables:

```systemverilog
// Inside testbench file
`ifdef DEBUG
    always @(negedge clk_i)
        $display("count=%0d empty=%b full=%b",
                 count_o, empty_o, full_o);
`endif
```