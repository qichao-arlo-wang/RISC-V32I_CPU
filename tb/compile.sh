#!/bin/bash

# Usage: ./assemble.sh <file.s>

# Default vars
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ASM_DIR="$SCRIPT_DIR/asm"
output_file="$SCRIPT_DIR/program.hex"

# Handle terminal arguments
if [[ $# -eq 0 ]]; then
    echo "Usage: ./assemble.sh <file.s>"
    exit 1
fi

# if input file is not absolute path, assume it is in asm directory
input_file=$1
if [[ "$input_file" != /* ]]; then
    input_file="$ASM_DIR/$input_file"
fi

# Check if input file exists
if [[ ! -f "$input_file" ]]; then
    echo "Error: Input file '$input_file' does not exist."
    exit 1
fi

basename=$(basename "$input_file" | sed 's/\.[^.]*$//')
parent=$(dirname "$input_file")
file_extension="${input_file##*.}"
LOG_DIR="$SCRIPT_DIR/test_out/$basename"

# Create output directory for disassembly, hex and waveforms
mkdir -p $LOG_DIR

riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 \
                        -o "a.out" "$input_file"

riscv64-unknown-elf-ld -melf32lriscv \
                        -e 0xBFC00000 \
                        -Ttext 0xBFC00000 \
                        -o "a.out.reloc" "a.out"

riscv64-unknown-elf-objcopy -O binary \
                            -j .text "a.out.reloc" "a.bin"

rm *dis 2>/dev/null

# This generates a disassembly file
# Memory in wrong place, but makes it easier to read (should be main = 0xbfc00000)
riscv64-unknown-elf-objdump -f -d --source -m riscv \
                            a.out.reloc > ${LOG_DIR}/program.dis

# Formats into a hex file
od -v -An -t x1 "a.bin" | tr -s '\n' | awk '{$1=$1};1' > "${output_file}"

rm "a.out.reloc"
rm "a.out"
rm "a.bin"

echo "Assembly and processing of '$input_file' completed successfully."
echo "Disassembly output is saved in: ${LOG_DIR}/program.dis"
echo "Hex file is saved in: ${output_file}"
