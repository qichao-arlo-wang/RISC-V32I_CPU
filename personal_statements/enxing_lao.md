# Tasks completed
## Lab 4
- register_file_tb.cpp
- checked and debugged top.sv
- debugged using gtkwave and fixed all modules to ensure that top.sv passes successfully
- addi.S, bne.S, testing.sh all written to debug individual instructions

### Learnings
- compile.sh converts the instructions written in the .S files to raw bytes in big endian format in program.hex. As a result, for each address in mem, the entire 32-bit instruction must be referenced by '''{mem[addr+3], mem[addr+2], mem[addr+2], mem[addr]}''' which concatenates 4 bytes. This is done in instr_mem.sv. Additionally, to prevent segmentation issues where addresses outside of scope are referenced, there is a check at the end to ensure that all addresses are within range, else instruction is set to a default value of 32'b0
- control_unit.sv is core to the instructions. Not only must instructions be decoded correctly via main_decoder, but the alu_sv must set flags according to alu_result correctly. This is especially important for branch instructions to function correctly. This is done by setting the zero flag according to the result of alu.sv.
- top.sv must be initialised correctly by conscientiously checking input and output bit widths and ensuring all the signals are correctly connected to each component. As verilator stops at any warnings, unused signal warnings can be turned on and off accordingly.

## Project
- sign_exten_tb.cpp

# Extension
## Other RISC-V instructions in ALU
### SLL
![Abnormality of SLL](/images/SLL.png)

When SLL is tested with an overflow where t0 = 0xA is tested with an overflow of 32, 0xA << 32 should be equal to 0 since there is an overflow to 33 bits.
However, as seen in the image above, although src_a = 0xA, src_b = 0x20 and alu_control = 0x2 which correlates to the signed left logical shift in the ALU, the output of the ALU in alu_result = 0xA instead of 0x0. This contributes to the value in a0 (which is the sum of output values) to be higher than expected value of 410 by 10.
![output of SLL test](/images/SLLtest.png)

### SLT
![output of SLT test](/images/SLTtest.png)