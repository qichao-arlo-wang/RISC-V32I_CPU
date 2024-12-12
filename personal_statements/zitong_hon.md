


# F1 Starting Light Program
Implementation of an F1 starting lights sequence using a simulated RISC-V processor, Verilator, and Vbuddy for visualization. I designed an assembly program to control the lights, simulating its execution on a processor, and displaying outputs on the Vbuddy interface.

## Implementation Details

### 1. RISC-V Assembly Program
The program (`F1Assembly.s`) implements the F1 lights sequence:
- **Logic for Lights**: Uses a shift register to sequentially turn lights ON, followed by a random delay to turn all lights OFF.
- **Random Delay**: Introduces a variable delay using a pseudo-random number generator to mimic real-world variability.

### Final Assembly code: 
```assembly
main:
    li t2, 0x2000             # Address for instruction fetch
    li t3, 0                  # Initialize delay counter
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

### Integration with Vbuddy

The Vbuddy testbench (`f1_tb.cpp`) was designed to analyse the behavior of the F1 starting lights sequence through neopixel bar visualisation using the `vbdBar` function. Each update reflects the current state of the lights as controlled by the RISC-V assembly program.

#### Testbench Implementation
The testbench iterates through simulation cycles, updating the Vbuddy interface with the current light state:
```cpp
for (int i = 0; i < max_cycles; ++i) {
    vbdBar(top->a0 & 0xFF);   // Neopixel bar updates
    runSimulation();          // Simulate one clock cycle
    usleep(5000);             // Adjustable delay
}
```
### Challenges and Changes
1. Timing Issues: The lights transitioned too quickly, making it difficult to observe the sequence visually. 
Solution: Introduced an adjustable delay (`unsleep`) between simulation cycles to slow down transitions:
```cpp
usleep(5000);  // Delay of 5 milliseconds
```
2. Random Timing Variations: Random delays were not noticeable, resulting in lights turning off uniformly.
Solution: Expanded the range of random delays in (`random_delay`) subroutine in (`F1Assembly.s`)

### Results
Sequential light activation on the neopixel bar and random timing was observed in light transitions.
[F1 Light](https://github.com/arlo-wang/Group-9-RISC-V/blob/9bec4edaada61815e805d215d8d00f31166c538f/images/TestEvidence/f1testingvid.mp4)

---

# Reference Program

## Introduction
This part of the project involve designing and testing a RISC-V processor that executes a program (`pdf.s`) to calculate a probability distribution function (PDF) for a set of input data. The goal was to process large memory files, calculate the PDF, and visualize the results using Vbuddy. The processor was simulated using Verilator with an integrated custom testbench.

## Objectives
1. Implement a RISC-V program to calculate the PDF.
2. Simulate the RISC-V processor using Verilator.
3. Process and visualize the PDF data with Vbuddy.
4. Automate the simulation flow using shell scripts.

---

## Key Components


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

|  Tag (22 bits)   | Set Index (8 bits) | Byte Offset (2 bits) |
| addr_i[31:10]    | addr_i[9:2]        | addr_i[1:0]          |

**Tag (22 bits)**: Used to match the requested memory address with the stored cache data
**Set Index (8 bits)**: Determines the specific cache set
**Byte Offset (2 bits)**: Will always be 0 for instruction cache
--

## **L1 Instruction Cache: 4-Way Set Associative**

### **Code Analysis:**
- **Initialization:** Arrays (`valid_array`, `tag_array`, `data_array`, and `lru_bits`) are cleared during reset using an `initial` block.
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

### **Challenges Addressed:**
1. **Cache Coherence:** Ensured consistency between caches using valid signals (`l2_cache_valid`, `l3_cache_valid`).
2. **Integration:** Sequential checking resolved by prioritizing L1 > L2 > L3.

---

## **Finally...**
The instruction cache functionality was verified through implementation of testbench to test instruction cache top-level module. Additionally, signal waveforms were analysed using GTKWave to ensure correct behavior and timing across all cache levels.

[Tests passed](https://github.com/arlo-wang/Group-9-RISC-V/blob/main/images/TestEvidence/instr_mem_sys%20test%20passed.png)

[GTKWAVE](https://github.com/arlo-wang/Group-9-RISC-V/blob/main/images/TestEvidence/instr__cache_passed.png)

