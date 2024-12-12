#!/bin/bash

# # Attach Vbuddy for windows user
# ./attach_usb.sh

# Cleanup previous build files
rm -rf obj_dir
rm -f verilated.vcd program.hex data.mem

# Set directories
SCRIPT_DIR=$(dirname "$(realpath "$0")") # tb directory
RTL_FOLDER=$(realpath "$SCRIPT_DIR/../rtl")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tests")
F1_FILE="${SCRIPT_DIR}/asm/F1Assembly.s"

# Assemble the PDF file
# Default path for generated program.hex is $TESTS_DIR/program.hex
./assemble.sh "${F1_FILE}"
if [ $? -ne 0 ]; then
    echo "Error: assemble.sh failed to execute."
    exit 1
fi

PROGRAM_PATH=$(realpath "$TEST_FOLDER/program.hex") # program.hex file path

# Cleanup previous build files
cd "$TESTS_DIR"
rm -rf obj_dir
cd "$SCRIPT_DIR"
rm -f verilated.vcd program.hex data.mem

# Copy instruction memory (program) hex file to current directory
cp "$PROGRAM_PATH" ./program.hex
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy program.hex from $PROGRAM_PATH"
    exit 1
fi

# Compile Verilog files with Verilator
verilator -Wall --cc --trace $RTL_FOLDER/top.sv \
          -y $RTL_FOLDER \
          --exe $TEST_FOLDER/f1_tb.cpp \
          --prefix Vdut \
          -CFLAGS "-isystem /opt/homebrew/Cellar/googletest/1.15.2/include"\
          -LDFLAGS "-L/opt/homebrew/Cellar/googletest/1.15.2/lib -lgtest -lgtest_main -lpthread" \

# Build the simulation executable
make -j -C obj_dir -f Vdut.mk Vdut

# Check if the simulation executable is created
if [ ! -f obj_dir/Vdut ]; then
    echo "Error: Simulation executable was not created. Exiting."
    exit 1
fi


# Copy the program.hex file to obj_dir
# if [ -f "$PROGRAM_PATH" ]; then
#     echo "Copying program.hex to obj_dir..."
#     cp "$PROGRAM_PATH" obj_dir/
# else
#     echo "Error: program.hex not found. Ensure it exists in $TEST_FOLDER."
#     exit 1
# fi


# Run the simulation
./obj_dir/Vdut

cd "$TESTS_DIR"
rm -f program.hex data.hex
cd "$SCRIPT_DIR"
rm -f program.hex data.hex