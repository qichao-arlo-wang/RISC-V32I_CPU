# Multilevel Data & Instruction Cache Implementation and Extensions

## Overview

   This document describes the design, implementation, and testing of both multilevel data cache and multilevel instruction cache in our RV32I-based processor. These optimisations reduce memory access time by prioritising frequently or recently accessed data.

## Design Goals

The design and implementation of both memory components were guided by the following objectives:

- **Compatibility**: Fully support the RV32I instruction set and allocate memory regions based on the [memory map](../images/personal_statements_images/mem_map.png) for enhanced debugging and visualization.
- **Scalability**: Ensure that the memory size and structure can be adjusted as required.
- **Simplicity**: Maintain clean and modular design to allow ease of integration and debugging.

### Key Features

1. Multilevel Cache Design

    - Implemented L1, L2, and L3 caches, providing a hierarchical cache system to improve instruction access efficiency.
    - Configurations:
  
        - **L1 Instruction Cache**: 4-way set-associative, 4KB size
        - **L2 Instruction Cache**: 4-way set-associative, 4KB size
        - **L3 Instruction Cache**: 8-way set-associative, 8KB size

2. Set-Associative Cache Design

    - Utilized a **4-way** set-associative approach for L1 and L2, and **8-way** set-associative for L3 to balance performance and hardware complexity.
    - Implemented an **LRU** (Least Recently Used) replacement policy to optimize cache line management and improve hit rates.
  
3. Parameterized Design for Flexibility

    - Designed the instruction cache using parameterized modules, allowing seamless reuse and easy adaptation for different cache sizes or levels.
    - Minimized redundant work and simplified integration with the existing pipeline.

---

### Structure

- **The caches uses a 32-bit memory address and is divided as follows:**

    ```
    | higher tag bits | set index | byte offset bits |
    |       [22]      |    [8]    |        [2]       |
    |  addr_i[31:10]  |   a[9:2]  |       a[1:0]     |
    ```

    | # of Bits | Part          | Purpose                                                |
    |-----------|---------------|--------------------------------------------------------|
    | 22        | `TAG`         | Identifies the data stored in the cache.               |
    | 8         | `SET INDEX`   | Determines the specific cache set.                     |
    | 2         | `BYTE OFFSET` | Specifies the exact byte in the cache line.(not used in Instruction Cache) |

- **4-way Set-Associative Cache**

    ```
    |       way1        |       way2        |       way3        |       way4        |
    |-------------------|-------------------|-------------------|-------------------|
    |  v    tag    data |  v    tag  | data |  v  | tag  | data |  v  | tag  | data |
    | [1]   [22]   [32] | [1]   [22] | [32] | [1] | [22] | [32] | [1] | [22] | [32] |
    ```

    | Component  | Description                                     |
    |------------|-------------------------------------------------|
    | `VALID`    | Indicates if the cache block contains valid data.|
    | `TAG`      | Matches the memory address tag.                 |
    | `DATA`     | Holds the actual cached data.                   |

---

### Key cache algorithem

Basic algorithem for both data cache and instruction cache are the same. The only difference is that we don't have to consider write operations in instruction cache.

- **Cache hit detection:**

  1. The cache hit detection checks all NUM_WAYS in a given set to determine if the tag stored in the cache matches the incoming tag (tag) and if the line is valid (valid_array).	This process is done by iterating through all ways in the set and comparing the tag of the cache line with the incoming `tag (tag_array[sets_index][i] == tag)` while ensuring that the `valid_array` for the line is set to 1.
  2. If a match is found:
     - The way_hit_flag is set to mark the corresponding way.
     - The cache is marked as a hit (hit_detected).
     - The corresponding data is read from data_array based on the byte_en_i (byte enable signal).

- **Cache Hit handling:**

  When a cache hit occurs:
  1. **Data Retrieval:**
    The data is read from the data_array for the corresponding way that had a hit. The byte_en_i signal ensures the correct part of the data is read (e.g., byte, half-word, or full-word).
  2. **LRU Update:**
    The Least Recently Used (LRU) counters are updated to reflect the access pattern:
     - The LRU counter for the way that had a hit is reset to 0 (most recently used).
     - Other ways in the same set increment their LRU counters unless they are already at the maximum value (NUM_WAYS-1).
  3. **Write Handling:**
    If `wr_en_i` is enabled, the hit line is updated with new data (wr_data_i) in the data_array using byte masking (byte_en_i).

- **Cache Miss Handling:**
  If no cache hit occurs `(hit_detected == 0)`, the system handles the cache miss as follows:
  1. **Check Data Validity:**
     - It checks whether the data from the next cache level (L2) is valid via the `l2_cache_valid_i` signal.
  2. **LRU Replacement:**
     - The line with the highest LRU counter value (least recently used) in the set is chosen for replacement.
     - This is determined by iterating over the LRU counters for all ways and selecting the line with the maximum value.
  3. **Load New Data:**
     - The tag of the evicted line is replaced with the incoming tag (tag_array), and the line is marked valid.
     - The new data is loaded into the data_array.
     - If `wr_en_i` is enabled, the new data is written with byte masking (byte_en_i). Otherwise, the incoming data from lower level is loaded into the line.
  4. **LRU Update:**
     - The LRU counter of the replaced way is reset to `0` (most recently used).
     - All other ways increment their LRU counters unless they are at the maximum value.

- **LRU Replacement Policy:**
  - Each way maintains a 3-bit LRU (Least Recently Used) counter.
  - Upon a cache hit, the LRU counter of the hit way is reset to `0` (most recently used), and other counters are incremented.
  - On a miss, the cache line with the **highest** LRU value (least recently used) is replaced with new data.

This approach ensures efficient cache management by prioritizing frequently accessed data while minimizing performance overhead.

---

### Testing evidence

The source code for the data and instruction caches is available in the [RTL folder](../rtl/), and the corresponding working evidence can be found in the [data_instr_cache_tests_evidence](../images/TestEvidence/) section.

## Conclusion

In this project, we successfully designed and implemented a simplified verison of multilevel data and instruction caches for our RV32I-based processor, focusing on performance improvement through efficient memory access. By utilizing a 4-way set-associative design for L1 and L2 caches, and an 8-way set-associative design for the L3 cache, along with the LRU replacement policy, we achieved a balance between complexity and efficiency.
