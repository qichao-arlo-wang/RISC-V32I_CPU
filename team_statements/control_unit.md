# Control Unit Implementation and Extensions

## Introduction
The control unit is integral to the operations of the processor, as it decodes the instruction and creates signals that "control" the processor, allowing the instructions to be executed acordingly.

## Components
- Main decoder
    - Determines flags based on op_code and funct_3 in instruction
- ALU decoder
    - Determines which ALU operation takes place
    - For branch instructions, default is SUB (subtraction)
- Control unit
    - Use ALU result as input to determine if branching occurs in single cycle processor

## Implementation
### Main decoder
Inputs and flag outputs
```systemverilog
module main_decoder (
    input logic [6:0] opcode_i,    // Opcode from instruction
    input logic [2:0] funct3_i,   // funct3 field from instruction

    output logic reg_wr_en_o,      // Register Write Enable
    output logic mem_wr_en_o,      // Memory Write Enable
    output logic [2:0] imm_src_o,  // Immediate source control
    output logic alu_src_o,  // ALU source (register or immediate or imm << 12)
    output logic branch_o,         // Branch control
    output logic result_src_o,     // Result source (ALU or memory)
    output logic [1:0] alu_op_o,   // ALU Operation control
    output logic [3:0] byte_en_o,   // Byte enable
    output logic alu_src_a_sel_o, // enable rd1 to be pc
    output logic signed_o
);
```
Only op_code and funct_3 are involved in determining which flags need to be enabled, because they determine what type of instruction is being taken.

### ALU decoder
ALU decoder correlates the instruction to the ALU operation it should take, by producing the output ALU_op depending on the operations in the ALU unit.
As all branch instructions involve calculating a difference between the 2 values, their ALU_op is always 4'h1 which is subtraction.

### Control unit
Control unit parses the input instruction into the input values required by the main decoder and ALU decoder modules. 

In the case of branching instructions, it checks the ALU result for whether the branch condition is achieved depending on the type of branch instruction (funct3) and if the instruction is a branch instruction (branch flag from main decoder).

## Pipelined processor
For pipelined control unit, the difference in implementation is explained in pipeline.md.

## Conclusion
The control unit works and ensures that all the instructions implemented can be done so by having all relevant flags and signals.
