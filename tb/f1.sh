#!/bin/bash

# Connect vbuddy
~/Documents/iacLAB-0/lab0-devtools/tools/attach_usb.sh

# #generate f1.mem
# riscv64-unknown-elf-as -march=rv32i -o F1Assembly.o F1Assembly.s #assemble your program
# riscv64-unknown-elf-objcopy -O binary F1Assembly.o F1Assembly.bin #generate binary file
# hexdump -v -e '"%08x\n"' F1Assembly.bin > f1.mem  #binary to hex mem file

# Formatting the testbench
sed -i 's/100000/2000/' tests/f1_vbuddy_tb.cpp
sed -i 's/PDF Program/F1 Program/' tests/f1_vbuddy_tb.cpp
sed -i 's/f1startX/f1start\*\//' tests/f1_vbuddy_tb.cpp
sed -i 's/Yf1end/\/\*f1end/' tests/f1_vbuddy_tb.cpp
sed -i 's/pdfstart\*\//pdfstartX/' tests/f1_vbuddy_tb.cpp
sed -i 's/\/\*pdfend/Ypdfend/' tests/f1_vbuddy_tb.cpp

# Formatting instructions in instr_mem
sed -i 's/program.hex/f1.mem/' /root/Documents/Group-9-RISC-V/rtl/instr_mem.sv
rm -rf obj_dir
rm -f top.vcd

 # Step 1: Compile the Verilog files along with the testbench
verilator -Wall --cc --trace /root/Documents/Group-9-RISC-V/rtl/*.sv \
--top-module top --exe tests/f1_vbuddy_tb.cpp vbuddy.cpp


# # Step 2: Build the executable for the simulation
make -j -C obj_dir/ -f Vtop.mk Vtop

 # Step 3: Run the simulation
./obj_dir/Vtop


# Run the simulation
#./doit.sh
