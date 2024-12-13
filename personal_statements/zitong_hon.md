# RISC-V RV32I Processor Coursework

## Personal Statement of Contributions

**Zi Tong Hon**

---

### Overview  
- [Data Memory](#data-memory)
- [ALU](#alu)
- [Register File](#register-file)
- [F1 Starting Light Program](#f1-starting-light-program)  
- [Reference Program](#reference-program)  
- [Instruction Cache System](#instruction-cache-system)  
    - [Multilevel Instruction Cache](#multilevel-instruction-cache)
- [Additional Comments](#additional-comments)

---

# Data memory
Initially, the data memory implementation posed challenges in accommodating different memory layouts, particularly when switching between `.mem` and `.hex` files for test and simulation purposes. Furthermore, ensuring compatibility with byte-level, half-word, and word-level operations required careful handling of memory address offsets and byte enables.

## Modifications
**Flexible File Handling**  
The `$readmemh()` SystemVerilog directive was adjusted to allow seamless switching between data sources, such as `triangle.mem` and `data.hex`. This made debugging and testing more modular by enabling different memory content configurations for varying test scenarios.  

```verilog
$readmemh(MEM_FILE, mem, 32'h00010000);
```
---

# ALU
The AlU required extensions to support additional RISC-V operations, such as unsigned comparisons, arithmetic right shifts and various logical operations. One of the challenge I encountered was to e sure correctness of my logical operatons while expanding functionality.

## Modifications
**Extended Operations**
1. Unsigned and signed shirt operations and logical operations like XOR, OR and AND are added. Operations like logical shift left immediate insturction (SLLI) becomes important later when we are creating and testing our f1 starting light program.

```verilog
4'h2: alu_result_o = src_a_i << src_b_i[4:0];  // Logical shift left
4'h6: alu_result_o = $signed(src_a_i) >>> src_b_i[4:0];  // Arithmetic shift right
```

2. Zero flag logic is implmented to identify conditions when the ALU result is zero (this is critical for branch operations).

```verilog
zero_o = (alu_result_o == 32'd0) ? 1'b1 : 1'b0;
```

# Register file
My inisitial challenge with the register file was ensuring proper handling of register `x0` (which must always remain zero) and efficiently supporting simultaneous read/writ eoperations.

## Modifications
1. 'Protecting' `x0`: Added logic to prevent overwriting register `x0` regardless of control signals. 

```verilog
reg_file[0] <= 32'b0;  // Register x0 is always zero
```

2. Improved read operations: Optimised asynchronous read to ensure correct data retrieval without interfering with writ eoperations.

```verilog
rd_data1_o = reg_file[rd_addr1_i];
rd_data2_o = reg_file[rd_addr2_i];
a0 = reg_file[10];  // Debugging output
```


# F1 Starting Light Program
Implementation of an F1 starting lights sequence using a simulated RISC-V processor, Verilator, and Vbuddy for visualisation. I designed an assembly program to control the lights, simulating its execution on a processor, and displaying outputs on the Vbuddy interface.

## 1. RISC-V Assembly Program
The program (`F1Assembly.s`) implements the F1 lights sequence:
- **Logic for Lights**: Uses a shift register to sequentially turn lights ON, followed by a random delay to turn all lights OFF.
- **Random Delay**: Introduces a variable delay using a pseudo-random number generator to mimic real-world variability.

### Simple Assembly code for testing: 
```assembly
main:
    li t2, 0x2000             # Address for instruction fetch
    li t3, 0                  # Initialise delay counter
    li t4, 0                  # Random delay timer
loop:
    lw s0, 0(t2)
    jal ra, subroutine        # Call subroutine for lights sequence
    li a0, 0xFF               # Turn all lights ON
    addi t3, t3, 1
    bge t3, t4, turn_off
    j loop

turn_off:
    li a0, 0x0                # Turn all lights OFF
    jal ra, random_delay
    j loop

random_delay:
    li t5, 10000000     # Max delay
    li t6, 10           # Min delay
    add t4, t3, t6      # t4 = t3 + min
    rem t4, t4, t5      # t4 = delay % max
    add t4, t4, t6      # Ensure delay is within range
    ret

```

## Integration with Vbuddy

This Vbuddy testbench (`f1_tb.cpp`) was designed to analyse the behavior of the F1 starting lights sequence through neopixel bar visualisation using the `vbdBar` function. Each update reflects the current state of the lights as controlled by the RISC-V assembly program.

#### Testbench Implementation
The testbench iterates through simulation cycles, updating the Vbuddy interface with the current light state:

## Challenge and Change
1. Random Timing Variations: Random delays were not noticeable, resulting in lights turning off uniformly.
Solution: Expanded the range of random delays in (`random_delay`) subroutine in (`F1Assembly.s`)

## Results
Sequential light activation on the neopixel bar and random timing was observed in light transitions.
[F1 Light](https://github.com/arlo-wang/Group-9-RISC-V/blob/9bec4edaada61815e805d215d8d00f31166c538f/images/TestEvidence/f1testingvid.mp4)

---

# Reference Program

## Introduction
During this part of the project, I integrated and tested our RISC-V processor running a refernece program (`pdf.s`) which calculates a probability distribution function (PDF) for a set of input data. The goal was to process large memory files, calculate the PDF, and plot the results via a Vbuddy Interface. 

Additionally, I needed to resolve issues related to memory formatting, addresses and pipelined hazards, as well as ensure that the testbench only starts plotting data after the PDF calculation is completed.

---

## Key Components

### 1. PDF Program (`pdf.s`)
This RISC-V assembly program calculates the PDF by:
- Initialising a PDF array (`base_pdf`) at memory addresses `0x00000100` to `0x000001FF`.
- Iterating through data stored at `0x00010000` to `0x0001FFFF`.
- Incrementing frequency bins in the PDF array based on input data.
- Displaying the PDF values via register `a0` in a loop for Vbuddy visualisation.

### 2. Data Memory (`data_mem.sv`)
This memory system was designed to:
- Use byte-addressed logic to simplify data handling.
- Load `.mem` files with `$readmemh`, ensuring alignment with processor expectations (e.g., data at `0x00010000`).

**Key Code:**
```verilog
logic [7:0] data_array [0:DATA_MEM_SIZE-1];
initial begin
    $readmemh("data.mem", data_array, 32'h00010000);
end
```

### 3. Testbench (`pdf_tb.cpp`)
This testbench simulates processor execution and interfaces with Vbuddy:
- Monitors the program counter (`pc`) and instructions.
- Waits for the processor to reach the display loop (`DISPLAY_LOOP_PC = 0x60`) before plotting results.
- Plots `a0` values to Vbuddy after PDF calculation.
- I added a boolean `pdf_build_done` so that it will only start plotting when a0 is not zero (function is build).

**Key Code:**
```cpp
bool pdf_build_done = false;
for (int i = 0; i < 1'000'000; ++i) {
    runSimulation(1);
    if (!pdf_build_done && (top->pc == DISPLAY_LOOP_PC)) {
        pdf_build_done = true;
        std::cout << "PDF build is complete. Starting to plot A0 values." << std::endl;
    }
    if (pdf_build_done && top->a0 != 0) {
        vbdPlot(int(top->a0), 0, 255);
    }
}
```

### 4. Automation Script (`pdf.sh`)
This script automates the build and simulation process:
- Copies the appropriate `.mem` file based on the selected dataset (e.g., `triangle.mem`).
- Compiles the Verilog code with Verilator.
- Runs the simulation executable and processes the output.

**Key Code:**
```bash
DATA_FILE="$1"
MEM_FILE="${DATA_FILE}.mem"
cp "${DATA_DIR}/${MEM_FILE}" "./data.mem"
verilator -Wall --cc --trace $RTL_DIR/top.sv \
          -y $RTL_DIR --exe $TB_DIR/pdf_tb.cpp
make -j -C obj_dir -f Vdut.mk Vdut
./obj_dir/Vdut
```
---

## Challenges and Changes

### Memory Addressing and Initialisation
**Issue:** Incorrect alignment between `.mem` files and processor memory caused invalid reads and writes. The program attempted to access invalid memory addressess which were out of range, leading to simulation warnings.   
**Solution:** I used `$readmemh` with starting addresses (`0x00010000`) to load data directly into the expected memory region. Additionally, I ensure the file path in `data_mem.sv` is correct before running my tests.

### Data Formatting
**Issue:** Non-uniform formatting in `.mem` files caused parsing errors.  
**Solution:** I standardised `.mem` files to use two-digit hex values for consistency (e.g., `00, FF`).

### Control Flow Debugging
**Issue:** The program counter (`pc`) did not align with expected instruction memory addresses.  
**Solution:** I identified the display loop start (`_loop3`) and updated `DISPLAY_LOOP_PC` in the testbench to `0x60`, matching the processor's internal address calculation.

### Simulation Efficiency
**Issue:** Continuous plotting slowed down the simulation.  
**Solution:** I implemented delayed plotting, `pdf_build_done` function, until after the PDF was built, reducing simulation overhead.

---

## Results
1. **Successful PDF Calculation:** The processor correctly calculated the frequency distribution for input data files.
2. **Efficient Visualisation:** The testbench plotted results only after the PDF was built, improving performance.
3. **Robust Automation:** The `pdf.sh` script streamlined the process, enabling easy testing with different datasets.

---

## Recap
Through developing and debugging my PDF testbench and System Verilog files, I realised that my previous approach of making significant changes to the logic of my code whenever an error appeared was not always effective. Instead, I learned to slowing down, carefully analysing error messages, and rereading the code to identify the root cause of issues. This shift in mindset allowed me to debug more efficiently.

---

# Instruction Cache System 
Implementation of a three-level instruction cache system, optimised for latency, associativity, and capacity. The cache hierarchy includes:
1. **L1 Instruction Cache:** 4-way set associative.
2. **L2 Instruction Cache:** 4-way set associative.
3. **L3 Instruction Cache:** 8-way set associative.
4. **Instruction Memory Top-Level Module:** Manages the sequential checking of cache levels and fallback to main memory.

---

## Instruction Cache Address Breakdown
Each cache uses a 32-bit memory address, divided into:

| Tag (22 bits)     | Set Index (8 bits) | Byte Offset (2 bits) |
|--------------------|--------------------|-----------------------|
| addr_i[31:10]     | addr_i[9:2]        | addr_i[1:0]          |


**Tag (22 bits)**: Used to match the requested memory address with the stored cache data
**Set Index (8 bits)**: Determines the specific cache set
**Byte Offset (2 bits)**: Will always be 0 for instruction cache
--

# Multilevel Instruction Cache
## **L1 Instruction Cache: 4-Way Set Associative**

### **Code Analysis:**
- **Initialisation:** Arrays (`valid_array`, `tag_array`, `data_array`, and `lru_bits`) are cleared during reset using an `initial` block.
- **Hit Detection:** Combines `valid_array` and `tag_array` to identify a hit for a given `addr_i`.
  ```verilog
  if (valid_array[sets_index][i] && tag_array[sets_index][i] == tag) begin
      l1_cache_hit_o = 1'b1;
      l1_cache_data_o = data_array[sets_index][i];
  end
  ```
- **LRU Update:** A replacement policy ensures the least recently used line is evicted on a miss.
  ```verilog
  if (hit_detected) begin
      lru_bits[sets_index][i] <= lru_bits[sets_index][i] < NUM_WAYS - 1 ? lru_bits[sets_index][i] + 1 : 0;
  end
  ```

### **Functionality:**
L1 provides fast access by reducing instruction fetch latency for frequently accessed instructions. 

---

## **L2 Instruction Cache: 4-Way Set Associative**

### **Code Analysis:**
- Similar to L1.
- Handles L1 misses and stores more instructions, reducing main memory accesses.

### **Key Differences:**
- **Valid Output:** Signals L1 about data availability using `l2_cache_valid_o`.

### **Example Code:**
```verilog
if (!cache_hit_o && l3_cache_valid_i) begin
    tag_array[sets_index][evict_way] <= tag;
    data_array[sets_index][evict_way] <= l3_cache_data_i;
    valid_array[sets_index][evict_way] <= 1'b1;
```

---

## **L3 Instruction Cache: 8-Way Set Associative**

### **Code Analysis:**
- **Increased Associativity:** 8-way associativity reduces conflict misses, crucial for the last cache level.
- **Integration with Main Memory:** Fetches data directly from `instr_mem` on a miss.
  ```verilog
  instr_o = cache_hit_o ? data_array[sets_index][i] : main_mem_data;
  ```

### **Functionality:**
L3 acts as the last cache level, significantly reducing main memory accesses for large workloads.

---

## **Top-Level Module: Instruction Memory System**

### **Code Overview:**
- Integrates all three cache levels and the main memory.
- Implements sequential hit checking using combinational logic.
  ```verilog
  assign instr_o = l1_cache_hit ? l1_cache_data :
                  (l2_cache_hit && l2_cache_valid) ? l2_cache_data :
                  (l3_cache_hit && l3_cache_valid) ? l3_cache_data :
                  main_mem_data;
  ```

## **Challenges Addressed:**
1. **Cache Coherence:** Ensured consistency between caches using valid signals (`l2_cache_valid`, `l3_cache_valid`).
2. **Integration:** Sequential checking resolved by prioritising L1 > L2 > L3.

---

## **Finally...**
The instruction cache functionality was verified through implementation of testbench to test instruction cache top-level module. Additionally, signal waveforms were analysed using GTKWave to ensure correct behavior and timing across all cache levels.

[Tests passed](https://github.com/arlo-wang/Group-9-RISC-V/blob/main/images/TestEvidence/instr_mem_sys%20test%20passed.png)

[GTKWAVE](https://github.com/arlo-wang/Group-9-RISC-V/blob/main/images/TestEvidence/instr__cache_passed.png)


# Additional Comments
If I were to undertake this project again, I would focus on improving early-stage planning, especially for pipeline and cache integration, to minimise debugging time later.

On top of my contributions to the debugging and testing of the control unit, data memory, and ALU, I also focused on ensuring the reference program functioned correctly after the pipeline was implemented. This involved testing in a pipelined environment and resolving any integration issues.

A particularly rewarding aspect of this project was the exceptional teamwork and support from my colleagues, to whom I owe much credit:

- Arlo’s constant availability and expertise during the implementation of the multilevel instruction cache were invaluable. His guidance helped me overcome challenges in understanding and debugging the cache functionality.

- Enxing’s thorough testing of all CPU instructions and her extensive debugging efforts ensured the design's stability. Her approach helped uncover and address even the smallest issues.

- Despite being ill, Keven’s dedication to implementing hazard units and resolving pipeline complexities was remarkable. His ensured the pipelined design was both functional and efficient.

Being part of such a collaborative and supportive team made the project both productive and enjoyable. This experience has enhanced my technical expertise and teamwork skills.