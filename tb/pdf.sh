#!/bin/bash

# This script connect vbuddy and tests the PDF data files
# Usage: ./pdf.sh [sine|triangle|gaussian|noisy]

# before running this script, make sure you have correct configuration in vbuddy.cfg
# and correctly connect the vbuddy to the computer

# Cleanup previous build files
rm -rf obj_dir
rm -f verilated.vcd program.hex data.mem

# Set directories
SCRIPT_DIR=$(dirname "$(realpath "$0")")          # tb directory
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")       # rtl directory
TESTS_DIR=$(realpath "$SCRIPT_DIR/tests")         # tests directory
PROGRAM_PATH=$(realpath "$TESTS_DIR/program.hex") # program.hex file
REFERENCE_DIR=$(realpath "$SCRIPT_DIR/reference") # reference data directory
PDF_FILE="${SCRIPT_DIR}/asm/pdf.s"


# Cleanup previous build files
cd "$TESTS_DIR"
rm -rf obj_dir
cd "$SCRIPT_DIR"
rm -f verilated.vcd program.hex data.mem


# Choose data file based on command line argument
# Usage: ./pdf.sh [sine|triangle|gaussian|noisy]
DATA_FILE="$1"

if [ -z "$DATA_FILE" ]; then
    DATA_FILE="triangle"  # default if no argument provided
fi

MEM_FILE="${DATA_FILE}.mem"
MEM_PATH="${REFERENCE_DIR}/${MEM_FILE}"

# Check if the chosen mem file exists
if [ ! -f "${MEM_PATH}" ]; then
    echo "Error: ${MEM_FILE} not found in ${REFERENCE_DIR}"
    echo "Please choose from: sine, triangle, gaussian, noisy"
    exit 1
fi

# Assemble the PDF file
# Default path for generated program.hex is $TESTS_DIR/program.hex
./assemble.sh "${PDF_FILE}"

# Copy instruction memory (program) hex file to current directory
cp "$PROGRAM_PATH" ./program.hex
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy program.hex from $PROGRAM_PATH"
    exit 1
fi

# Copy the chosen data memory file as data.mem
cp "${MEM_PATH}" "./data.hex"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy ${MEM_FILE} from ${MEM_PATH}"
    exit 1
fi

# Compile Verilog files with Verilator
verilator -Wall --cc --trace $RTL_FOLDER/top.sv \
          -y $RTL_FOLDER \
          --exe $TESTS_DIR/pdf_tb.cpp \
          --prefix Vdut \
          -CFLAGS "-isystem /opt/homebrew/Cellar/googletest/1.15.2/include"\
          -LDFLAGS "-L/opt/homebrew/Cellar/googletest/1.15.2/lib -lgtest -lgtest_main -lpthread" \

# Build the simulation executable
make -j -C obj_dir -f Vdut.mk Vdut

# Check if the simulation executable was created
if [ ! -f obj_dir/Vdut ]; then
    echo "Error: Simulation executable not created."
    exit 1
fi

# Run the simulation
./obj_dir/Vdut

cd "$TESTS_DIR"
rm -f program.hex data.hex
cd "$SCRIPT_DIR"
rm -f program.hex data.hex