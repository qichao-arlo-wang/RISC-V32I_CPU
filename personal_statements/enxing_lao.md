# Introduction

As the main tester and debugger of the team, my work has laid less with writing the system verilog files, but more of understanding what my team has written, running the tests provided and writing further tests, and checking gtkwave and making amendments to the code where necessary. These changes were heavily time consuming as I needed to spend time understanding what had been done, what was the corrected expected output and what was wrong, so that I could isolate the problem and implement fixes where needed. Strong team communication allowed me to quickly ask my teammates where I was unable to understand what had been done, in order to find the issue and fix it.

Due to system issues, I was unable to run tests involving Vbuddy or write and run bash scripts, which is where my teammates came in to help run. These usually took place when I had completed verifying that the processor functions well using the 4 provided tests (1_addi_bne, 2_li_add, 3_lbu_sb and 4_jal_ret). If there were any issues, I would take main responsibility for debugging.

# Overview
- Lab 4
    - Writing C++ testbench for sign extension unit and register file
    - Testing and debugging
- Single cycle
    - Refactoring control unit and related modules (ALU decoder, main decoder)
    - Testing and debugging
- Pipeline
    - Testing and debugging 
- Stretch goal: Implementing full RISC-V processor
    - Writing assembly language programs to test other instructions
    - Running and debugging

# Tasks completed
## Lab 4
- initial teething problems occurred with segmentation fault occurring
- after attending lab session to receive help from UTA, this issue was promptly fixed by referencing the correct .h script
- initially, 1_addi_bne did not pass so addi.S, bne.S, testing.sh all written to debug individual instructions
- once branching logic was fixed by adding extra branch_condition in control_unit by making use of the zero flag and using that to determine if branch is 1 so that branch is taken

## Single cycle
- Instructions were strictly implemented using the protocol in [RISCV Reference](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf). This ensures that even upon further extension of the instructions, there will not be unforeseen errors
![I-type instructions](images/personal_statements_images/enxing_lao_images/image.png)
As can be seen from the instructions for SRLI and SRAI, the opcode and funct3 codes are the same. Similarly, for SLLI and SRLI, both opcode and funct7 codes are the same. Hence, to fully differentiate between the different types of instructions, the decoder must implement checks on opcode, funct3 and funct7 in full.

- ALU decoder and main decoder were edited to increase readibility and commented heavily.
- Main work was done in the top.sv to ensure that all units are integrated correctly.
    - Unlike Lab 4, where there were only 2 types of instructions being used, the instructions now include load, store and jump instructions.
    - top.sv was heavily manipulated to add conditions based on the instruction in order to choose the correct inputs to the ALU

### Work on top.sv
- ALU instructions for register vs immediates as operands
    - alu_src is the selector for the alu_src_b_mux that selects the immediate or data from read register 2 to be used in the ALU unit operation.
    - As there is not signed and unisnged operations, there is a signed_bit in control_unit called signed_o.
    - The signed bit in signed_o affects the sign extension of immediate in sign_exten.sv.
- Load instructions
    - Result from ALU must be used as the input address for the data_mem.
- Store instructions
    - Result from ALU is used as the input address for the data_mem
    - Data input to data memory is data in register of register address 2
- Branch instructions
    - Branch condition expanded from lab4, to include all the possible branch conditions in control_unit.sv
    - Additional input in control_unit.sv for alu_result to be inputted such that its value can be compared.
    - All branch conditions use the ALU operation for subtract, such that the output value of the ALU unit is compared against 0 to check for conditions involving BLT/BGE/BLT/BGEU
    - Finally, if the instruction is a branch instruction, then branch is 1. pc_src_o = branch AND branch condition
- JAL and JALR instructions
    - These are both unconditional jumps, hence pc_src_o = 1 in control_unit.sv.
    - Main_decoder.sv ensures that result_src = 1
    - In order for rd = PC+4, multiple muxes are used to enable this
    1. data_mem_pc_next ensures that data_to_use = PC+4
    2. data_mem_mux has result_src = 1 such that result = data_to_use = PC+4
    3. register_file has input result which is PC+4
    - For JAL: PC += imm. For JALR: PC = rs1 + imm
    In top.sv
    ```systemverilog
        always_comb begin
            case (op)
                7'b1100111: begin //JAL
                    option2 = rd_data1;
                end
                default: option2 = pc; // JALR
            endcase
        end
        adder alu_adder(
            .in1_i(option2),
            .in2_i(imm_ext),
            
            .out_o(pc_target)
        );
    ```
    This adder is used for all branch instructions and also for JAL and JALR. For JALR, the first operand is always equal to PC, which is the same as all th other branch instructions. Hence, option2 = pc is the default case. Only in the case for JAL instruction, where PC = rs1 + imm
    pc_target is used in pc_reg to determine the next instruction.

- LUI and AUIPC instructions
    - The shift of Imm << 12 is done in the sign_exten.sv under U-type instructions
    ```systemverilog
            3'b011:       
        // U-type
        // imm = instruction[31:12] = instr_31_7_i[24:5]
        // lower 12 bits are extended with zeros    
        imm_ext_o = {instr_31_7_i[24:5], 12'b0};
    ```
    - For LUI: rd = 0 + imm << 12. For AUIPC: rd = PC + imm << 12
    Hence, if it is an LUI instruction, src_a = option = 32'b0.
        ```systemverilog
        always_comb begin
            case (op)
                7'b0110111: option = 32'b0; // LUI
                default: option = pc; // AUIPC
            endcase
        end
        ```

### Learnings
- compile.sh converts the instructions written in the .S files to raw bytes in big endian format in program.hex. As a result, for each address in mem, the entire 32-bit instruction must be referenced by '''{mem[addr+3], mem[addr+2], mem[addr+2], mem[addr]}''' which concatenates 4 bytes. This is done in instr_mem.sv. Additionally, to prevent segmentation issues where addresses outside of scope are referenced, there is a check at the end to ensure that all addresses are within range, else instruction is set to a default value of 32'b0
- control_unit.sv is core to the instructions. Not only must instructions be decoded correctly via main_decoder, but the alu_sv must set flags according to alu_result correctly. This is especially important for branch instructions to function correctly. This is done by setting the zero flag according to the result of alu.sv.
- top.sv must be initialised correctly by conscientiously checking input and output bit widths and ensuring all the signals are correctly connected to each component. As verilator stops at any warnings, unused signal warnings can be turned on and off accordingly.

## Project
- sign_exten_tb.cpp

# Extension
## Other RISC-V instructions in ALU
### SLL
![Abnormality of SLL](/images/personal_statements_images/enxing_lao_images/SLL.png)

When SLL is tested with an overflow where t0 = 0xA is tested with an overflow of 32, 0xA << 32 should be equal to 0 since there is an overflow to 33 bits.
However, as seen in the image above, although src_a = 0xA, src_b = 0x20 and alu_control = 0x2 which correlates to the signed left logical shift in the ALU, the output of the ALU in alu_result = 0xA instead of 0x0. This contributes to the value in a0 (which is the sum of output values) to be higher than expected value of 410 by 10.
![output of SLL test](/images/personal_statements_images/enxing_lao_images/SLLtest.png)

### SLT
![output of SLT test](/images/personal_statements_images/enxing_lao_images/SLTtest.png)

### SLTU
![waveform of SLTU test](/images/personal_statements_images/enxing_lao_images/SLTUwaveform.png)
As seen in this image, at the second clock cycle, a0 remains = 0x1 as the output is 0 because the unsigned comparison of 10 and -10 is such that -10 is larger. Thus, there is no addition. At the third clock cycle, a0 increases by 1. This is the opposite at the SLT waveform.