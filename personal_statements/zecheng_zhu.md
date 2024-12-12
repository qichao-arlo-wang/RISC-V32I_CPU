# RV32I Processor Coursework

## Personal Statement of Contributions  
*Zecheng Zhu*  
- I have serval git commit name to upload to repo: zechneg, zzczjh9, or Keven Zhu due to serval device I used
- Also some of commits are collaborating together with team mates and uploaded using their laptop

---

### Overview  

- [Sign Extension Unit](#sign-extension-unit)  
- [Control Unit](#control-unit)
  - [Main Decoder](#main-decoder) 
  - [ALU Decoder](#alu-decoder)
- [ALU](#alu)
- [Pipeline](#pipeline)  
  - [Registers](#registers) (4 flip flop & original register negedge)  
  - [Hazard Unit](#harzard-unit)
  - [top.sv](#top.sv)   
- [F1 Program](#f1-program)  
  - [Assembly Program](#assembly-program)  
  - [LFSR Logic Random Delay](#lfsr-logic-random-delay)  
- [FPGA Implementation](#fpga-implementation)  


---

## Contributions  

### Sign Extension Unit  
I made this module for both lab4 and our full single cycle RISC, this module is clear based on follwing picture and implemented by setting `imm_src` for each type of instructinos
![Instruction_Map](images/personal_statements_images/zecheng_zhu_image/sign_exten.png)
| ImmSrc | Instruction Type |
|--------|------------------|
| 000    | I tyoe       |
| 001    | S type          |
| 010    | B type           |
| 011    | U type            |
| 100    | J type  |
| 101    | SLLI, SRLI, SRAI  |
| default| 0  |


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
I wrote all 4 pipeline flip-flops, register file, hazard unit and also implement the pipeline version of top.sv from our test-passed single cycle full RISC processor

---

### F1 Program  

#### Assembly Program
*Explain the addition or modification of the SLLI instruction and how it contributes to the program.*  

#### LFSR Logic Random Delay 
*Provide an overview of the F1 program, including its purpose and any features you implemented.*  

---

### Reference Program  

#### Features Added  
*List and describe the new features you added to the reference program.*  

#### Testing  
*Summarize the testing process and results, emphasizing your role in ensuring the program's reliability.*  

---

### Additional Notes  
*Optional: Include any further comments about your learning experience, challenges overcome, or goals achieved.*  

---

*Date: 2023-12-07*
