# RISC-V Processor Pipeline Overview

![pipeline structure](/images/pipeline_structure.jpg)


The provided diagram includes color-coded annotations for clarity:
- **Blue**: control signals for registers and hazard unit.
- **Red**: additional mux signals for execution stage
- **Green**: add-on signals to writeback stage.

## 5 stage

### 1. Fetch
- Instruction is fetched as per the single-cycle processor

### 2. Decode 
- Instruction is decoded to derive:
  - op_code
  - src_a, src_b for alu
  - alu_control (determine operation in ALU)

#### Differing implementation from single cycle
- For branch instructions, due to the ALU unit being in the execution stage, it is not possible to determine the branch flag at this stage. Hence, branch condition is taken out of control_unit.sv. op_code and funct_3 are propagated out of the control unit too because they determine which branch instruction is being evaulated
- For load instructions, differing from the single cycle processor,
there was only a single signal called mem_byte_en that was enabled for both load and store instructions to signal if the data is byte, half or word. An additional load flag was created in order to differentiate between store and load instructions, because only store instructions will raise a hazard.

### 3. Execution
- Result of ALU is computed here since ALU block is in execution stage
- In the event that instruction is a branch instruction (determined by op_e that is propagated to the execution stage from op_d), then the ALU_result and the zero flag from the ALU unit will determine if the branch flag is 1 for a branch to occur

From top.sv in pipeline branch,
```systemverilog
  // Compute Branch Condition
  always_comb begin
      case (funct3_e)
          3'b000: branch_condition_e = eq_e;                      // beq: branch if zero is set
          3'b001: branch_condition_e = ~eq_e;                     // bne: branch if zero is not set
          3'b100: branch_condition_e = ($signed(alu_result_e) < 0);          // blt
          3'b101: branch_condition_e = eq_e | ($signed(alu_result_e) > 0); // bge
          /* verilator lint_off UNSIGNED */
          3'b110: branch_condition_e = (alu_result_e < 0);           //bltu 
          /* verilator lint_on UNSIGNED */
          3'b111: branch_condition_e = eq_e | (alu_result_e > 0);  //bgeu
          default: branch_condition_e = 1'b0;                       // Other branch types not implemented here
      endcase
  end
```

### 4.Memory 
- The main unit here to be used is the data_mem_sv that has inputs for address, memory write, byte enable and byte read 
- For memory to be loaded and stored correctly, mem_byte_en must not be 0. 


### 5.Write Back
- In pipelining, to prevent data hazards, write backs to registers occur at the falling edge of the clock cycle instead of the rising edge.


## Pipeline Control and Hazards
  - **Forward_a/b**: Addresses data hazards by selecting the correct operand to to forward signals from each stage based on wr_en at m/w stages.
  - 2 separate MUXes for src_a and src_b which are forward_a_e_o and forward_b_e_o respectively
    ```
    // MUX for forward_b_e_o
    // 10 : alu_result_m : forwarding from M state when refister writen_en on at M stage and register same as E stage
    // 01 : result_w : forwarding from W state when refister writen_en on at W stage and register same as E stage
    // 00 : rd_addr2_e : same as no pipeline for all other condition
    ```
  - **Stalls**: if load instruction's register overlap with register in execution stage
    ```systemverilog
    // Load Instruction --> Stall
    // When both 1: There is Load Instruction in the Execution stage
    //           2: Register used to write at Execution stage Overlapped with one of register are used in Decoding Stage
        
    //mem_ byte_en used for load (3 case depends on bit used)
    if ((load_flag_e_i == 1) && ((wr_addr_e_i == rd_addr1_d_i) || (wr_addr_e_i == rd_addr2_d_i))) begin
      stall_o = 1'b1;
    ```
  - When a load instruction is taken, to prevent data hazard, stall signal is high to determine whether pause the pc register for next instruction. Hence, the stall takes 1 cycle and for that 1 cycle, all inputs and outputs are the same as the previous cycle.
  ```systemverilog
  if (!stall) begin
    if (rst) begin  
      pc_o <= 32'h0;
    end
    else begin
      pc_o <= pc_next_i;
    end
  end
  ```
- **Flushes**: if branch is taken
  ```systemverilog
      // Branch happen / Jump instruction  ---> flush
      if (pc_src_i) begin 
        flush_o = 1;
      end
  ```
- When a branch instruction is taken, to prevent control hazard, flush signal is high to clear the instr_o for next instruction.
  ```systemverilog
   if (flush_i) begin
            // On flush, clear instruction and branch signals
            instr_d_o <= 0;
            op_code_d_o <= 0;
            func_3_d_o <= 0;
  ```

## Testing and Insights
### Instruction Testing
Run ./doit.sh verify.cpp which tests the pipeline program against all the assembly language tests that are in the (tb/asm) folder.

Issue with branching logic and flush hazard was first discovered at 1_addi_bne. Fix is described in section on Differing Implementation.

### PDF testing
Run ./f1.sh <sine, triangle, gaussian, noisy> to connect the Vbudy and input the according .mem file into the data memory.

On running PDF tests, an issue with the stall logic was identified, where it was found that although the other data inputs are all stalled successfully, pc_fetch does not stall, which results in the next instruction not decoded and hence not executed. Hence, the fix describe in the stall section above in pc_reg is described.


## Conclusion
All tests run successfully in pipeline. The output seen on Vbuddy when the pdf tests are run are also the same. Although one instruction now takes 5 clock cycles to complete instead of only 1 clock cycle, the pipelined processor is likely faster, as the throughput remains 1 instruction per cycle while the time taken for 1 clock cycle is now the maximum time taken of any of the 5 stages.
