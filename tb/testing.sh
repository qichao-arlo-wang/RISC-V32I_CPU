#!/bin/bash

# Directories
RTL_DIR="/root/Documents/Group-9-RISC-V/rtl"
TB_DIR="/root/Documents/Group-9-RISC-V/tb"
TEST_CPP="$TB_DIR/tests/top_tb.cpp"
TOP_MODULE="top"  # Top module name

# Output directory for Verilator
OBJ_DIR="$TB_DIR/obj_dir"

# Check if Verilator is installed
if ! command -v verilator &> /dev/null; then
    echo "Verilator could not be found. Please install it first."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OBJ_DIR"

# Step 1: Compile Verilog code to C++ using Verilator
echo "Compiling Verilog source files with Verilator..."

# Collect all .sv files in the RTL directory
VERILOG_FILES=$(find "$RTL_DIR" -name "*.sv" | tr '\n' ' ')

verilator --cc $VERILOG_FILES \
          --Mdir "$OBJ_DIR" \
          --exe "$TEST_CPP" \
          --top-module "$TOP_MODULE" \
          --Wno-lint \
          -I"$RTL_DIR"      # Add the RTL directory to the include path

# Step 2: Compile generated C++ files
echo "Building the generated C++ simulation executable..."
cd "$OBJ_DIR" || exit
make -f "V${TOP_MODULE}.mk"

# Step 3: Run the simulation
echo "Running the simulation..."
./"V${TOP_MODULE}"

# Step 4: Clean up (optional)
echo "Cleaning up generated files..."
rm -rf "$OBJ_DIR"

echo "Test completed."
