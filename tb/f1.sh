#!/bin/bash

# Formatting the testbench
sed -i 's/1300000/2000/' tb/tests/f1_vbuddy_tb.cpp
sed -i 's/PDF Program/F1 Program/' tb/tests/f1_vbuddy_tb.cpp
sed -i 's/f1startX/f1start\*\//' tb/tests/f1_vbuddy_tb.cpp
sed -i 's/Yf1end/\/\*f1end/' tb/tests/f1_vbuddy_tb.cpp
sed -i 's/pdfstart\*\//pdfstartX/' tb/tests/f1_vbuddy_tb.cpp
sed -i 's/\/\*pdfend/Ypdfend/' tb/tests/f1_vbuddy_tb.cpp

# Formatting instructions in ROM
sed -i 's/pdf.mem/f1.mem/' rtl/rom.sv

# Run the simulation
./doit.sh

#generate f1.mem
# riscv64-unknown-elf-as -march=rv32i -o F1Assembly.o F1Assembly.s #assemble your program
# riscv64-unknown-elf-objcopy -O binary F1Assembly.o F1Assembly.bin #generate binary file
# hexdump -v -e '"%08x\n"' F1Assembly.bin > f1.mem #binary to hex mem file

