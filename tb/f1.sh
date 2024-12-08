#!/bin/bash

# Attach Vbuddy
./attach_usb.sh

# Cleanup previous build files
rm -rf obj_dir
rm -f verilated.vcd

# Set directories
RTL_DIR="/root/Documents/Group-9-RISC-V/rtl"
TB_DIR="/root/Documents/Group-9-RISC-V/tb/tests"
HEX_FILE="$TB_DIR/program.hex"

# Compile Verilog files with Verilator
verilator -Wall --cc --trace $RTL_DIR/top.sv \
          -y $RTL_DIR \
          --exe $TB_DIR/f1_tb.cpp \
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
    echo "Error: program.hex not found. Ensure it exists in $TB_DIR."
    exit 1
fi

# Run the simulation
./obj_dir/Vdut
