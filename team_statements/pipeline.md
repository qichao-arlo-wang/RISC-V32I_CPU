# RISC-V Processor Pipeline Overview

![pipeline structure](/images/pipeline_structure.jpg)


The provided diagram includes color-coded annotations for clarity:
- **Blue**: control signals for registers and hazard unit.
- **Red**: additional mux signals for execution stage
- **Green**: addon signals to writeback stage.

## 5 stage

### 1. Fetch
- flush determines whether clear the instr_o for next instruction

  ```systemverilog
   if (flush_i) begin
            // On flush, clear instruction and branch signals
            instr_d_o <= 0;
  ```
- stall determines whether pause the pc register for next instruction
  ```systemverilog
  if (!stall) begin
            if (rst) begin  
                pc_o <= 32'h0;
            end

            else begin
                pc_o <= pc_next_i;
            end
        end```

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
    ```
            // MUX for forward_b_e_o
            // 10 : alu_result_m : forwarding from M state when refister writen_en on at M stage and register same as E stage
            // 01 : result_w : forwarding from W state when refister writen_en on at W stage and register same as E stage
            // 00 : rd_addr2_e : same as no pipeline for all other condition

    ```
  
- **Control Hazards**:
  - Flushes: if branch occurs
  - stalls: if load instruction 's register overlap with register in execution stage

  ```systemverilog
          // Branch happen / Jump instruction  ---> flush
        if (pc_src_i) begin 
            flush_o = 1;
        end

        // Load Instruction --> Stall
        // When both 1: There is Load Instruction in the Execution stage
        //           2: Register used to write at Execution stage Overlapped with one of register are used in Decoding Stage
        
        //mem_ byte_en used for load (3 case depends on bit used)
        if ((load_flag_e_i == 1) && ((wr_addr_e_i == rd_addr1_d_i) || (wr_addr_e_i == rd_addr2_d_i))) begin
            stall_o = 1'b1;



