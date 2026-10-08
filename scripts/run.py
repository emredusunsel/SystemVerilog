#!/usr/bin/env python3

# Executes terminal commans from Python
import subprocess
# Read command-line arguments and controls exit codes
import sys
# Handles file and directory paths
from pathlib import Path

# Define the project root
    # __file__: A Python variable containing the path of the current Python script.
    # Path(__file__): Converts the sting into a `Path` object.
    # .resolve(): Converts the path to an absolute path and resolves symbolic links.
    # .parent: Returns the parent directory.
ROOT = Path(__file__).resolve().parent.parent # ROOT = /SystemVerilog

# Defines a function named `run_test`.
    # `name` is an argument supplied when calling the function.
def run_test(name):
    # Locate RTL and testbench files
    rtl = ROOT / "rtl" / f"{name}.sv"
    tb = ROOT / "tb" / f"{name}_tb.sv"

    # Defines the directory where Verilator should generate its files.
    build = ROOT / "build" / name

    # Creates the directory
        # parents=True: Automatically creates missing parent directories.
        # exist_ok=True: Prevents Python from raising an exception when the directory already exists.
    build.mkdir(parents=True, exist_ok=True)

    # Construct the Verilator command.
    # Each element represents one command-line argument.
    compile_cmd = [
        "verilator",
        "-o",  "../sim_"f"{name}",
        "-j", "4",
        "--binary",
        "--timing",
        "--assert",
        "--coverage-user",
        "--top-module", f"{name}_tb",
        "--Mdir", str(build),
        str(rtl),
        str(tb)
    ]

    # Execute the compilation
    print(f"[BUILD] {name}")

    # Python starts a seperate process that executes the compile_cmd.
    result = subprocess.run(compile_cmd)

    # Check compilation status.
    if result.returncode != 0:
        print(f"[FAIL] {name}: Compilation failed")
        return False # Immediately exits run_test().

    # Locate the simulation executable
    executable = build.parent / f"sim_{name}"

    print(f"[RUN] {name}")

    # Run the simulation.
    result = subprocess.run([
        str(executable),
        "+verilator+quiet"
        ], cwd=ROOT)

    # Check simulation status.
    if result.returncode != 0:
        print(f"[FAIL] {name}: Simulation failed")
        return False

    # Return success.
    print(f"[PASS] {name}")
    return True


if __name__ == "__main__":
    # Check command-line arguments.
        # len(): Returns the number of elements in a collection.
            # python3 scripts/run.py dff => sys.argv = ["scripts/run.py", "dff"]
            # len(sys.argv) == 2
    if len(sys.argv) != 2:
        print("Usage: python3 run.py <test_name>")
        sys.exit(1)

    # Start the test
        # Recall: sys.srgv[1] = "dff" => success = run_test("dff")
    success = run_test(sys.argv[1])

    # Exit with the correct status.
    sys.exit(0 if success else 1)