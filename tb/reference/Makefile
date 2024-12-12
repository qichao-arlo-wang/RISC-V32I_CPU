# Make file to assembly RISC-V assembly language program(s) in myprog folder
#   ... relocate instruction to start at 0xBFC00000
#   ... output hex file ready to be read into instruction memory

clean:
	@rm -f *.hex *.asm *.out *.bin

reference: pdf.s
	@riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o pdf.out pdf.s
	@riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o pdf.out.reloc pdf.out
	@riscv64-unknown-elf-objcopy -O binary -j .text pdf.out.reloc pdf.bin
	@riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases pdf.out.reloc > pdf.asm
	@set -euo pipefail
	@od -v -An -t x1 pdf.bin | tr -s '\n' | awk '{pdf=pdf};1' > pdf.hex
	@rm pdf.out
	@rm pdf.out.reloc
	@rm pdf.bin

reference: F1Assembly.s
	@riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o F1Assembly.out F1Assembly.s
	@riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o F1Assembly.out.reloc F1Assembly.out
	@riscv64-unknown-elf-objcopy -O binary -j .text F1Assembly.out.reloc F1Assembly.bin
	@riscv64-unknown-elf-objdump -D -S -l -F -Mno-aliases F1Assembly.out.reloc > F1Assembly.asm
	@set -euo pipefail
	@od -v -An -t x1 F1Assembly.bin | tr -s '\n' | awk '{F1Assembly=F1Assembly};1' > F1Assembly.hex
	@rm F1Assembly.out
	@rm F1Assembly.out.reloc
	@rm F1Assembly.bin
