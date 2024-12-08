#!/bin/bash

# Attach Vbuddy
./attach_usb.sh

# Cleanup previous build files
rm -rf obj_dir
rm -f verilated.vcd program.hex data.mem

# Set directories
RTL_DIR="/root/Documents/Group-9-RISC-V/rtl"
TB_DIR="/root/Documents/Group-9-RISC-V/tb/tests"
PROGRAM_PATH="/root/Documents/Group-9-RISC-V/tb/test_out/5_pdf/program.hex"
DATA_DIR="/root/Documents/Group-9-RISC-V/tb/reference"

# Choose data file based on command line argument
# Usage: ./pdf.sh [sine|triangle|gaussian|noisy]
DATA_FILE="$1"

if [ -z "$DATA_FILE" ]; then
    DATA_FILE="triangle"  # default if no argument provided
fi

MEM_FILE="${DATA_FILE}.mem"
MEM_PATH="${DATA_DIR}/${MEM_FILE}"

# Check if the chosen mem file exists
if [ ! -f "${MEM_PATH}" ]; then
    echo "Error: ${MEM_FILE} not found in ${DATA_DIR}"
    echo "Please choose from: sine, triangle, gaussian, noisy"
    exit 1
fi

# Copy instruction memory (program) hex file to current directory
cp "$PROGRAM_PATH" ./program.hex
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy program.hex from $PROGRAM_PATH"
    exit 1
fi

# Copy the chosen data memory file as data.mem
cp "${MEM_PATH}" "./data.mem"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy ${MEM_FILE} from ${MEM_PATH}"
    exit 1
fi

# Compile Verilog files with Verilator
verilator -Wall --cc --trace $RTL_DIR/top.sv \
          -y $RTL_DIR \
          --exe $TB_DIR/pdf_tb.cpp \
          --prefix Vdut \
          -CFLAGS "-I/usr/include/gtest" \
          -LDFLAGS "-L/usr/lib -lgtest -lgtest_main -lpthread"

# Build the simulation executable
make -j -C obj_dir -f Vdut.mk Vdut

# Check if the simulation executable was created
if [ ! -f obj_dir/Vdut ]; then
    echo "Error: Simulation executable not created."
    exit 1
fi

# Run the simulation
./obj_dir/Vdut
