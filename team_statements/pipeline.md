# RISC-V Processor Pipeline Overview

![pipeline structure](/images/pipeline_structure.jpg)


The provided diagram includes color-coded annotations for clarity:
- **Blue**: control signals for registers.
- **Red**: additional signal muxes for execution stage
- **Green**: add on signals to writeback stage.

## 5 stage

### 1. Fetch
- flush determines whether clear the instr_o for next instruction

  ```systemverilog
   if (flush_i) begin
            // On flush, clear instruction and branch signals
            instr_d_o <= 0;
  ```

### 2. Decode 
- if flush or stall --> clear all wr_en and branch signals but all other signals propagate as previous

### 3. Execution

### 4.Memory 

### 5.Write Back


## Pipeline Control and Hazards



## **Hazard Unit**
Manages data and control hazards:
- **Data Hazards**:
  - **Forward_a/b**: Selects the correct operand to to forward signals from each stage based on wr_en at m/w stages.
- **Control Hazards**:
  - Flushes: if branch occurs
  - stalls: if load instruction 's register overlap with register in execution stage



