# Introduction

As the main tester and debugger of the team, my work has laid less with writing the system verilog files, but more of understanding what my team has written, running the tests provided and writing further tests, and checking gtkwave and making amendments to the code where necessary. These changes were heavily time consuming as I needed to spend time understanding what had been done, what was the corrected expected output and what was wrong, so that I could isolate the problem and implement fixes where needed. Strong team communication allowed me to quickly ask my teammates where I was unable to understand what had been done, in order to find the issue and fix it.

Due to system issues, I was unable to run tests involving Vbuddy or write and run bash scripts, which is where my teammates came in to help run. These usually took place when I had completed verifying that the processor functions well using the 4 provided tests (1_addi_bne, 2_li_add, 3_lbu_sb and 4_jal_ret) as the baseline. If there were any issues, I would take main responsibility for debugging.

My role in this project often took place earlier, because my debugging came in most handy when working on core components such as the control unit, as if these core components do not function, we would not be able to move forward. Extensions were built on top of these core components. My work was the milestone to the team's progress, as they needed me to complete verification before they could move on.

# Summary of contributions
- Lab 4
    - Writing C++ testbench for sign extension unit
    - Testing and debugging
- Single cycle
    - Refactoring control unit and related modules (ALU decoder, main decoder)
    - Testing and debugging
- Pipeline
    - Testing and debugging 
- Stretch goal: Implementing full RISC-V processor
    - Writing assembly language programs to test other instructions
    - Running and debugging

# Lab 4
## Challenges
- Initial teething problems occurred with segmentation fault occurring.
- 1_addi_bne did not pass so addi.S, bne.S, testing.sh all written to debug individual instructions.
## Solutions
- After attending lab session to receive help from UTA, this issue was promptly fixed by referencing the correct .h script.
- Once branching logic was fixed by adding extra branch_condition in control_unit by making use of the zero flag and using that to determine if branch is 1 so that branch is taken.
- Wrote sign_exten_tb.cpp. The module passed this test successfully.

# Single cycle
## Instruction implementation
- Instructions were strictly implemented using the protocol in [RISCV Reference](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf). This ensures that even upon further extension of the instructions, there will not be unforeseen errors. This rigor was highly useful, because it ensured that if there were any errors further down, they could be easily isolated by referring to this document.

![I-type instructions](images/personal_statements_images/enxing_lao_images/image.png)
As can be seen from the instructions for SRLI and SRAI, the opcode and funct3 codes are the same. Similarly, for SLLI and SRLI, both opcode and funct7 codes are the same. Hence, to fully differentiate between the different types of instructions, the decoder must implement checks on opcode, funct3 and funct7 in full.

- ALU decoder and main decoder were edited to increase readibility and commented heavily.
- Main work was done in the top.sv to ensure that all units are integrated correctly.
    - Unlike Lab 4, where there were only 2 types of instructions being used, the instructions now include load, store and jump instructions.
    - top.sv was heavily manipulated to add conditions based on the instruction in order to choose the correct inputs to the ALU

### Work on top.sv
These work were done in conjunction with debugging. While testing tests 1, 2, 3, 4, I was also considering how to implement the other instructions by thinking about what modules would overlap and where I would need to add an additional mux. If an additional mux needed to be implemented, then an additional selector signal would be required. It was helpful that I refactored the control unit and had a deep understanding of its function. However, there were times where I backtracked where I realised that my teammates had already accounted for this and their method of doing was better.

For example, for the LUI and AUIPC instruction, I initially wrote out a mux in top.sv to select imm << 12 instead of imm. However, I removed this when I realised that sign_exten already accounts of this case by having an additional imm << 12. This approach in sign_exten was better because I could treat the immediate as per the other instructions involving immediates instead of adding complexity with the extra mux.
```systemverilog
// always_comb begin
//     case (op)
//         7'b0110111: imm = imm_ext << 12; // LUI
//         7'b0010111: imm = imm_ext << 12; // AUIPC
//         default: imm = imm_ext;
//     endcase
// end
```

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

## Learnings
- Many hours were spent debugging the control unit using the 4 provided tests, as this was our first iteration of the complete unit. Additionally, I was not yet familiar with the use of gtkwave. Although the 4 provided tests did not fully implement the entire instruction set, they involved all the different types of instructions involving branching, immediate and register arithmetic operations and load operations. Hence, once these 4 tests were passed, there were no significant issues in further tests.
- control_unit.sv is core to the instructions. Not only must instructions be decoded correctly via main_decoder, but the alu_sv must set flags according to alu_result correctly. This is especially important for branch instructions to function correctly. This is done by setting the zero flag according to the result of alu.sv.
- top.sv must be initialised correctly by conscientiously checking input and output bit widths and ensuring all the signals are correctly connected to each component. As verilator stops at any warnings, unused signal warnings can be turned on and off accordingly.

# Pipelined processor
## Control hazard and branch logic
When testing the pipeline by running each instruction test in (tb/asm), I realised that branches were not successfully taken. 
By checking on gtkwave, I narrowed the pc_src flag which was always 0. Hence, by relooking at the entire integration of all units, I realised that the ALU unit was not in the decode stage, but rather in the execute stage. This meant that adjustments to the control_unit must be made. I described this in further detail in pipeline.md.

Even after fixing this error, while branches were taken, I noticed that the output was still wrong. 
Going into futher detail on gtkwave, I realised that the branch takes place after the branch instruction completes execution stage. However, the instruction that was in decode stage was propagated to the execute stage, which resulted in errors because this is the next instruction if the branch is not taken. 
Hence, I checked the flush logic which signalled that a flush is correctly raised but the implementation of flush was not correct. Then, I amended reg_d_e to the following. To flush the instructions that were decoded. Since op_code, branch and funct_3 are all at a default value of 0 which means that there is no instruction, the other flags do not matter.
```systemverilog
always_ff @(posedge clk_i) begin
    if (flush_i || stall_i) begin
        // Flush some control signalbranch-related signals
        mem_wr_en_e_o <= 0;
        reg_wr_en_e_o <= 0;
        branch_e_o <= 0;
        opcode_e_o <= 0;
        funct3_e_o <= 0;
```
This fix was easily executed because of the strong adherence to the instructions reference in the design of the control unit.

## Data hazard
Although instruction tests 1, 2, 3, 4 all ran correctly, when the pdf test was tested on the pipeline, Zecheng and I realised that the output was wrong. Hence, my debugging skills came in again.

By manually writing down exactly what instruction is supposed to produce in terms of flags, outputs and register values, we were able to isolate the problem to first that flag mem_byte_en was not high when it should be. 
At first, I thought that there was a problem with the logic for the load and store instructions for flag mem_byte_en, but this was not the case as a previous load instruction executed correctly. 
Hence, I looked in detail again and realised that it was because due to the stall instruction, the pc had ended up skipping an instruction because unlike the rest of the processor, it did not stall for 1 cycle as well.
Although finding this bug took Zecheng and I 3 hours, the fix only took a few minutes.

```systemverilog    
always_ff @(posedge clk or posedge rst) begin
    if (!stall) begin
        if (rst) begin  
            pc_o <= 32'h0;
        end

        else begin
            pc_o <= pc_next_i;
        end
    end
end
```

# Full RISC-V instruction set
## Assembly test creation
When designing the single cycle processor, as I had written in accordance to the RISCV reference, I had already implemented all the instructions. However, they were not tested yet. Hence, I wrote assembly language programs in (tb/asm) and added their respective tests in (tb/tests/verify.cpp) based on the final expected value in a0.

In total, on top of the 4 provided instruction tests, I wrote an additional 11 tests. Programs that test arithmetic instructions test both instructions with register and immediate operands. For instructions that have both signed and unsigned, these were tested separately to ensure that both instructions function independently.


Writing these assembly language code was tedious, because I also had to manually calculate what were the expected values. In order to ensure that these tests were easily understandable, I wrote extensive comments to explain them. It was also important to me that the processor did not pass these tests by fluke, hence even if it passed without any problem, I would check the gtkwave to ensure that each step corroborates with my expectations.

## Interesting observations
Here are some of the more interesting results that I would like to highlight.
### SLL
![Abnormality of SLL](/images/personal_statements_images/enxing_lao_images/SLL.png)

When SLL is tested with an overflow where t0 = 0xA is tested with an overflow of 32, 0xA << 32 should be equal to 0 since there is an overflow to 33 bits.
However, as seen in the image above, although src_a = 0xA, src_b = 0x20 and alu_control = 0x2 which correlates to the signed left logical shift in the ALU, the output of the ALU in alu_result = 0xA instead of 0x0. This contributes to the value in a0 (which is the sum of output values) to be higher than expected value of 410 by 10.
![output of SLL test](/images/personal_statements_images/enxing_lao_images/SLLtest.png)
A fix is not implemented on this abnormality because it seems to be a flaw of system verilog, as the code is correct. Additionally, I am wary of overengineering, as such an overflow is unlikely in the first place because it is meaningless to shift by 32 bits as the expected value is 0. Hence, rather than trying to fix this and adding additional signals that would give rise to unnecessary complexity.

### SLT
![output of SLT test](/images/personal_statements_images/enxing_lao_images/SLTtest.png)

### SLTU
![waveform of SLTU test](/images/personal_statements_images/enxing_lao_images/SLTUwaveform.png)
As seen in this image, at the second clock cycle, a0 remains = 0x1 as the output is 0 because the unsigned comparison of 10 and -10 is such that -10 is larger. Thus, there is no addition. At the third clock cycle, a0 increases by 1. This is the opposite of the SLT waveform.

# Good practices
1. Add comments on code that I had just grasped so that I would not have to relearn it.
2. Comment out code that I wanted to remove, verify that it works, then remove.
3. Know exactly what is supposed to happen before and during testing. Having a piece of paper to write down and keep track of signals, outputs and PC were very helpful.
4. Take a break when needed. After spending a solid 6 hours testing and fixing, I had been stuck on the jalr (4_jal_ret) test for 2 hours. I decided to rest and try again tomorrow, the next day, it only took me 10 minutes to find the error and fix it.
5. Be wary of success. The reason why the pipelined processor managed to pass all 4 instruction tests but fail on the pdf test was because it passed the lbu instruction by fluke. This resulted in us not being able to identify the problem in the stall logic earlier and address this. In my work thereafter, I have made it a habit to check gtkwave even if it passes.

# Conclusion
In my role as main tester and debugger, I needed to have a strong understanding of the instructions and quickly grasp the code written in a short period of time so that I knew exactly what I should expect to see and compare that expectation versus the results in gtkwave, in order to identify the exact issue in the code. 
To make fixes, I also had to exercise a certain wariness, because blindly implementing fixes may fix this problem but create problems on others. It would be quite inconvenient to fix an issue, then mess it up again while fixing another issue, making me have to go back and fix it again. 
Yet, it was also important to be daring in making amendments to the code, especially there are a lot of dependencies. Strong version control gave me the confidence to make them, because I knew that I would be able to easily revert these changes.


In order of testing:
- **Single cycle processor** passes all 15 tests.
- **Pipelined processor** passes all 15 tests.
- **Full RISCV CPU (with cache)** passes 15 tests.

My extensive test writing allowed my teammates to check the work they had done.
Additionally, knowing that the same tests passed on other processor allows my teammates to isolate any issues more effectively.

Most significant contributions:
1. Single cycle processor branch logic
2. Pipelined processor branch logic and control hazard handling (flush)
3. Pipelined processor stall logic
4. Full RISCV instruction set implementation and testing

