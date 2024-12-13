# Personal Statement - Arlo Wang

## Table of Contents

- [Personal Statement - Arlo Wang](#personal-statement---arlo-wang)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Contributions](#contributions)
    - [Instruction \& data memory](#instruction--data-memory)
      - [Challenge \& Reflections](#challenge--reflections)
    - [Multilevel caches](#multilevel-caches)
    - [Data caches](#data-caches)
    - [Instruction caches](#instruction-caches)
      - [Challenges \& Reflections](#challenges--reflections)
    - [Shell scripts \& Makefile](#shell-scripts--makefile)
    - [Integration](#integration)
    - [Overall reflections](#overall-reflections)
    - [Acknowledgements](#acknowledgements)

## Introduction

In this project, I implemented [instruction and data memory](#instruction--data-memory) based on the provided memory map, successfully designed [L1, L2, and L3 data caches](#data-caches) and [L1, L2 and L3 instruction caches](#instruction-caches). While building the L1 data cache, I used parameterized designs to ensure flexibility, allowing L2, L3 caches, and even parts of the instruction cache to be adapted with minimal modifications. Finally, I developed relevant [shell scripts & Make files](#shell-scripts--makefile) to enable direct testing of F1 light and pdf via vbuddy.

In this personal statement, I will not discuss the detailed design of individual modules; these details can be found in the [team_statements](../team_statements/) folder.

## Contributions

### Instruction & data memory

In this project, I implemented the instruction and data memory and subsequently made modifications and optimizations while working on the cache components. The detailed design can be found at the [memory.md](../team_statements/memory.md). Final data_mem commit can be found [here](https://github.com/arlo-wang/Group-9-RISC-V/commit/4f32ed7df8a7603b5adbb3edb4d536253bae9f51). Final instr_mem commit can be found [here](https://github.com/arlo-wang/Group-9-RISC-V/commit/776af3a42230b57cfc7f65bfe9d4eb8e858cdcaa#diff-e7d99d33aee3f3f3423144fc4b3f8b18007793ac9e0701e37d065acd4d649f47).

#### Challenge & Reflections

- In this part, I gained an understanding of how memory operates and how to design the mem module to allocate vbuddy memory to instr_mem and data_mem according to the [memory map](../images/personal_statements_images/mem_map.png). Additionally, I developed a deeper understanding of memory alignment in RISC-V, particularly the importance of minimal alignment and its implications for instruction and data accesses. I explored how instructions like lh, lw, and lhu interact with memory, handling different word sizes and alignment constraints.
  
- While implementing instr_mem, I initially designed both read and write operations as synchronous and added bypass write logic to optimize it. However, this significantly increased the complexity of the pipeline and cache design, making it unmanageable within the given timeframe. Therefore, I opted to simplify the design by changing read to asynchronous, which reduced complexity and ensured smooth integration.

----

### Multilevel caches

### Data caches

I independently implemented the **L1, L2, and L3 data caches**, ensuring they are functional and parameterized for flexibility. The design retains the same interface as the original **data_mem** module, enabling seamless integration with other components. By parameterizing the L1 cache, I minimized the effort needed to adapt the structure for L2, L3 data caches, or even parts of the instruction cache. Specifically, the data caches were designed with the following configurations:

- L1 data cache: 4-way set-associative, 4KB size
- L2 data cache: 4-way set-associative, 4KB size
- L3 data cache: 8-way set-associative, 8KB size

Most of the data cache implementation was completed across two branches and detailed design of the data caches can be found in the [memory.md](../team_statements/memory.md) document:

- In **data_cache branch**, I implemented the L1 data cache, with supporting evidence available [data_cache branch commits history](https://github.com/arlo-wang/Group-9-RISC-V/commits/data_cache/), including the implementation of the L1 cache logic and LRU mechanism.

- In **data-cache-multilevel branch**, I further completed and optimized the L1, L2, and L3 data caches, and developed the new data_mem_sys.sv modulem. Working evidence, such as cache hierarchy optimizations and parameterization for flexibility, is available in the [data-cache-multilevel branch commit history](https://github.com/arlo-wang/Group-9-RISC-V/commits/data-cache-multilevel/)

------

### Instruction caches

The overall structure is quite similar to the previously implemented data_cache with **L1, L2, L3 instruction caches**, thanks to the design of the data_cache, which provided a solid foundation for the instruction cache implementation. It is also relatively simpler, primarily due to two factors: the reduced number of write operations and the absence of the need to handle the lower two bits, as the lower two bits of risc-v instructions are always 00. Specifically, the instruction caches were designed with the following configurations:

- L1 instruction cache: 4-way set-associative, 4KB size
- L2 instruction cache: 4-way set-associative, 4KB size
- L3 instruction cache: 8-way set-associative, 8KB size

Most of the instruction cache implementation was completed across two branches:

- In **instr_cache branch**, I implemented the L1 instruction cache, with supporting evidence available [instr_cache branch commits history](https://github.com/arlo-wang/Group-9-RISC-V/commits/instr_cache/), including the implementation of the L1 instruction cache logic and LRU mechanism.

- In **instr_cache_multilevel branch**, I further completed and optimized the L1, L2, and L3 instruction caches, and developed the new instr_mem_sys.sv modulem. Working evidence is available in the [instr_cache_multilevel branch commit history](https://github.com/arlo-wang/Group-9-RISC-V/commits/instr_cache_multilevel)

#### Challenges & Reflections

Through this part of the project, I gained a deeper understanding of how caches operate in real systems. While the implementation is simplified, it helped me grasp key concepts such as set-associative cache design, LRU (Least Recently Used) replacement, and cache hits/misses.

- The first challenge I faced was managing communication between cache levels, as their interaction logic proved to be crucial. At first, I attempted to determine data validity by writing a specific pattern like DEADBEEF, but this method was unreliable and difficult to scale, especially when handling real data. To resolve this, I introduced a **valid signal** for each cache level to explicitly indicate whether the data was valid or required fetching from lower levels. This approach simplified the communication logic and made the system more robust and efficient.
- In the initial design, I used the top 22 bits of the address as the tag bits and the middle 8 bits as the set index. However, although the addresses are different, some addresses have the same tag and set index, which caused data corruption. After carefully examining the waveforms, I identified this issue and temporarily included the bottom 2 bits in the tag bits to differentiate the data, resolving the current conflict. This experience made me realize the importance of designing the set index and tag bit division more rigorously to avoid similar issues in the future.
- In a real system, additional mechanisms like **stalling** and **flushing** would be required to handle cache misses and pipeline dependencies, which highlights the complexity of practical cache systems.

-------

### Shell scripts & Makefile

In this part, I primarily modified and debugged the **doit.sh**, **pdf.sh**, and **f1.sh** scripts by correcting the file paths and refining the compilation process. I added relevant commands to clean intermediate files, ensuring the repository remains more organized and concise. Additionally, I updated the Makefile to include support for f1.sh, simplifying the workflow for testing and execution.

-------

### Integration

In this part, I primarily focused on integrating the **single-cycle top layer** and the **final full RV32I design**.

1. **Single-Cycle Top Layer Integration:**
   
   I integrated all the single modules, including the instruction memory, data memory, and individual components, to create a unified top layer for the single-cycle version. This integration ensured that all individual components worked together seamlessly as a complete system. 

   **Evidence can be found in the** [commit history](https://github.com/arlo-wang/Group-9-RISC-V/commit/ee74586b7e9335e03b3ddfbad1bc1f3cdc62ff05)

2. **Full RV32I Design Integration:**

    In this part, I integrated the L1, L2, and L3 data caches, the L1, L2, and L3 instruction caches, and the pipelined version of the RV32I processor. This integration required careful coordination between the cache hierarchy, pipeline logic, and memory modules to ensure correct operation.

    **Supporting evidence for this integration can be found in the following commit history**:

-------

### Overall reflections

-------

### Acknowledgements

This project has been a challenging yet rewarding experience, and I am deeply grateful for the support and guidance I received from many individuals throughout this period.

First and foremost, I would like to extend my sincere gratitude to Professor Cheuang for delivering insightful and engaging lectures, which provided a solid foundation for this project. I am also thankful to the Teaching Assistants for their patience and support during the lab sessions. Finally, I want to express my appreciation to my teammates for their dedicated efforts and contributions. This project would not have been possible without their efforts and contributions!
