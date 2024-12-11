#!/bin/bash

# # Attach Vbuddy
# ~/Documents/iacLAB-0/lab0-devtools/tools/attach_usb.sh

# Cleanup previous build files
rm -rf obj_dir
rm -f verilated.vcd

# Set directories
SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")
HEX_FILE="$TEST_FOLDER/program.hex"

# Compile Verilog files with Verilator
verilator -Wall --cc --trace $RTL_FOLDER/top.sv \
          -y $RTL_FOLDER \
          --exe $TEST_FOLDER/top_tb.cpp \
          --prefix Vdut \
          -CFLAGS "-I/usr/include/gtest" \
          -LDFLAGS "-L/usr/lib -lgtest -lgtest_main -lpthread"

# Build the simulation executable
make -j -C obj_dir -f Vdut.mk Vdut

# Check if the simulation executable is created
if [ ! -f obj_dir/Vdut ]; then
    echo "Error: Simulation executable was not created. Exiting."
    exit 1
fi

# Copy the program.hex file to obj_dir
if [ -f "$HEX_FILE" ]; then
    echo "Copying program.hex to obj_dir..."
    cp "$HEX_FILE" obj_dir/
else
    echo "Error: program.hex not found. Ensure it exists in $TEST_FOLDER."
    exit 1
fi

# Run the simulation
./obj_dir/Vdut
