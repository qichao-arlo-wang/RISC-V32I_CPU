# RV32I Processor Coursework

## Personal Statement of Contributions  
*Zecheng Zhu*  
- I have serval git commit name to upload to repo: zecheng, zzczjh9, or Keven Zhu due to serval device I used
- Also some of commits are collaborating together with team mates and uploaded using their laptop

---

### Overview  

- [Sign Extension Unit](#sign-extension-unit)  
- [Control Unit](#control-unit)
  - [Main Decoder](#main-decoder) 
  - [ALU Decoder](#alu-decoder)
- [ALU](#alu)
- [Pipeline](#pipeline)  
  - [Registers](#registers) 
  - [Hazard Unit](#harzard-unit)
  - [top.sv](#top.sv)
  - [Testing](#tesing)   
- [F1 Program](#f1-program)   
- [FPGA Implementation](#fpga-implementation)  


---

## Contributions  
To check detailed implemention
- access Sign Extension Unit, Control Unit, ALU at [sincle cycle statement](../team_statements/single_cycle.md)
- access Pipeline at [Pipeline statement](../team_statements/pipeline.md)
- access F1 Program at [F1 Program statement](../team_statements/f1.md)

### Sign Extension Unit  
I made this module for both lab4 and our full single cycle RISC, this module is clear based on follwing picture and implemented by setting `imm_src` for each type of instructinos
![Instruction_Map](images/personal_statements_images/zecheng_zhu_image/sign_exten.png)
| ImmSrc | Instruction Type |
|--------|------------------|
| 000    | I tyoe           |
| 001    | S type           |
| 010    | B type           |
| 011    | U type           |
| 100    | J type           |
| 101    | SLLI, SRLI, SRAI |
| default| 0                |


---

### Control Unit 
This essential module decode the information from the 32 bit instruction and give clear information about other module how to behave to achive the goal, our team made control unit with the combination of main decoder and alu decoder. I firstly wrote it for lab4 and single cycle, these modules were the enhanced by arlo and enxing during testing proces.

#### Main Decoder 
This module decodes the `opcode` and `funct3` fields of RISC-V instructions to generate control signals for operations like register/memory access, ALU operations, and branching. I partially implemented this based on the RISC instruction cards which supports instruction types including s load, store, register, branch, jump, and immediate operations by setting output signals like `branch` and `result/alu_src` appropriately. 

#### Alu Decoder 
This moduel used `alu_op` from main decoder and `func3` field from instruction to output the `alu_control` signal to alu to perform respective actions
`alu_op` is assigned by main decoder for each type instruction with a default value zero, where `func3` indicates any specific arithmatic operation that need to be done.

---

### ALU 
This module is also straightforward, I set the result equals to different operation of input `a` and `b` upon its 'alu_control` recieved from alu_decoder module 

---

### Pipeline  
I wrote all 4 pipeline flip-flops, register file, hazard unit and also implement the pipeline version of top.sv from our test-passed single cycle full RISC processor, then I test this with enxing for instructions and pdf.

#### Registers
Each stage (Fetch, Decode, Execute, Memory, and Write Back) is separated by pipeline registers that hold the outputs of one stage and feed them into the next.  When a flush occurs due to a branch/jump, the pipeline registers between f & d stages clear instruction or branch signals to ensure subsequent stages do not process invalid operations. Also, registers between d & e will clear branch signal and writen&mem enable if flush or stall. All other stage registers behave like normal flip flops. 
In addition the register file is writen backs at the falling edge of the clock cycle instead of the rising edg to avoid conflict with other instructions

#### Hazard Unit
- **Forwarding**:  
I implemented a forwarding logic detects and routes the most recent ALU results from the Memory (M) or Write-Back (W) stages directly to the Execution (E) stage input muxes (`forward_a` and `forward_b`).  
  - Logic 
    If `wr_en` is active at the M stage and the destination register matches the source register in E, the ALU result from M is forwarded to E.
    If `wr_en` is active at the W stage and the destination register matches the source register in E, the result from W is forwarded.


- **Stall Condition**:  
  The hazard unit will assign stall high when the instruction in the Execution stage is a load, and its destination register matches a source register needed in the Decode stage of the subsequent instruction. Since the data from a load is only available after the Memory stage, the pipeline must wait one cycle.
  
  When a stall occurs, the PC and pipeline registers for the current cycle are held constant. The next instruction’s fetch is delayed, ensuring the load’s data is ready before the dependent instruction proceeds.

- **Flush Condition**:  
  Control hazards occur when a branch or jump instruction alters the program counter, invalidating instructions already fetched or decoded under the wrong assumption. When a taken branch is detected (`pc_src_i` asserted), a flush signal is generated.
  
  The flush signal clears the pipeline registers at the decode stage, discarding incorrect instructions. This prevents executing instructions from the wrong path and maintains architectural correctness.


#### Top.sv
- Based on the single cycle top.sv, I add 4 register and harzard unit, with serval additional signals like `load_flag` to detect load instruction for `stall`
- 2 mux are added at execution stage to forwarding signals from each stage to avoid data harzard; 2 mux are added at writeback stage to choose `read_data`, `pc_plus_4`, and `alu_result`
- I find really helpful to firstly draw the structure diagram and then check any issues

#### Testing
During testing, I cooperate with enxing to debug using `gtkwave`. Although the waveform is too long, but we find out our issues by check the current signal with the supposed one calculated from assembly code. The debugging process is a really time consuming but patience is really helpful.

---

### F1 Program  

I wrote the assembly code [F1Assembly.s](../tb/asm/F1Assembly.s) and `f1_tb.cpp` to implement the F1 light on Vbuddy, Working on this assembly-level LED control project has been an insightful exercise in understanding the delicate interplay between hardware control and software logic:

1. **Timing Loops**: Implementing delays in assembly using simple loops emphasized the need for precise cycle counting. While such loops are not efficient or scalable (in real-world systems you'd use timers or interrupts), they are instructive for learning fundamental control flow techniques.

2. **Pseudo-Randomness with LFSR**: Incorporating an LFSR for generating random delays was a tangible lesson in how randomness can be simulated in hardware-like environments without complex libraries. Observing how the shift and XOR operations produce a sequence of seemingly unpredictable values was both educational and satisfying.

3. **Debugging at the Lowest Level**: Any errors in assembly are typically stark — code might fail to run, loop infinitely, or produce nonsensical values. Debugging these issues improved problem-solving skills and reinforced an understanding of the underlying instruction set and processor state.

#### Learning 
- **Hardware-Software Integration**: By using Vbuddy to visualize register values as LEDs, the project underscored how software directly translates into hardware action. This real-time feedback loop made the learning more concrete.
- **Delays and Timers**: Writing custom delays demystified timing at a low level. Understanding that every loop iteration costs a finite number of cycles helped connect the dots between CPU frequency, instructions per cycle, and temporal behavior of programs.
- **Simple Randomness Techniques**: Using an LFSR demonstrated how to achieve pseudo-randomness without complex math or large code constructs. It also illustrated how hardware designers might introduce variability in systems without relying on external randomness sources such as python or c++ function.


---

### FPGA Implementation
After completing the RTL design and verification stages, I proceeded to implement and test the design on actual hardware. The target platform was a Terasic De10-Lite FPGA board, and the development environment used was Intel’s Quartus Prime Lite Edition. The goal was to synthesize, fit, and ultimately program the FPGA with the RTL. After Initialize all .sv files, I did

   - Utilized the De10-Lite User Manual and board schematics to determine which FPGA pins corresponded to LEDs, switches, and other peripherals.
   - Used the Pin Planner in Quartus Prime Lite to assign signals from the HDL design to the correct FPGA pins.
   [Pin_assignment](../images/TestEvidence/pin_assignment.png) 
   - Ran synthesis and fitting to ensure that the design was correctly mapped onto the FPGA logic cells, block RAM, and I/O pins.
   [Compile](../images/TestEvidence/fpga_compile.png)

*Date: 2024-12-13*
