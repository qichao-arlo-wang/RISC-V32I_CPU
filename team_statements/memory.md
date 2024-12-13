# Data and Instruction Meory Implementation

## Overview

   This document describes the design, implementation, and testing of Data Memory and Instruction Memory in our RV32I-based processor. The two memory components serve critical roles in storing instructions and managing data access, ensuring the functionality and efficiency of our system.

## Design Goals

The design and implementation of both memory components were guided by the following objectives:

- **Compatibility**: Fully support the RV32I instruction set and allocate memory regions based on the [memory map](../images/personal_statements_images/mem_map.png) for enhanced debugging and visualization.
- **Scalability**: Ensure that the memory size and structure can be adjusted as required.
- **Simplicity**: Maintain clean and modular design to allow ease of integration and debugging.

## Data Memory

### Key Features

- **Single-Port Synchronous Write, Asynchronous Read**:
  
  Write operations occur synchronously on the rising edge of the clock, controlled by a Write Enable signal (`wr_en_i`) and Byte Enable signals (`byte_en_i`).
  
  Read operations are asynchronous, enabling faster data access and bypassing clock dependency.

- **Configurable Memory Size**:
  
  Supports a total memory size of 128KB (addressable range `0x0000 0000` to `0x0001 FFFF`).

- **Byte-Level Addressing**:
  - Implements fine-grained byte enable signals for partial-word accesses:
  
    Byte (8 bits): Controlled by `4'b0001`.

    Half-Word (16 bits): Controlled by `4'b0011`.

    Word (32 bits): Controlled by `4'b1111`.
- **Memory Initialization**:

  Memory content can be preloaded using an external file (`data.hex`) starting at a configurable offset (`0x0001 0000`).

- **Default Read Logic**:

  Returns `32'hDEADBEEF` when no valid read access occurs (`byte_en_i == 4'b0000`) to indicate uninitialized or reserved memory.

### Implementation Details

- **Input Ports**: clk, addr_i, wr_en_i, wr_data_i, byte_en_i
- **Output Ports**: main_mem_valid_o, main_mem_rd_data_o
- **Memory Array**: Implemented as a 2D array:

    ```verilog
    localparam DATA_MEM_SIZE = 128 * 1024; // From `0x0000 0000` to `0x0001 FFFF`
    logic [7:0] mem [0:DATA_MEM_SIZE-1];
    ```

- **Access Logic**:
  - Write operation occurs only when Write Enable (we) is high.
  - Byte masking achieved using Byte Enable signals.

    ```verilog
    always @(posedge clk) begin
            if (we) begin
                    if (byte_en[0]) memory_array[addr][7:0] <= write_data[7:0];
                    if (byte_en[1]) memory_array[addr][15:8] <= write_data[15:8];
                    if (byte_en[2]) memory_array[addr][23:16] <= write_data[23:16];
                    if (byte_en[3]) memory_array[addr][31:24] <= write_data[31:24];
            end
    end

    assign read_data = memory_array[addr];
    ```

## Instruction Memory

### Purpose

The Instruction Memory module stores program instructions and outputs the instruction corresponding to the current Program Counter (PC) value during execution.

### Key Features

- **Read-Only**: The instruction memory is read-only during program execution and initialized using an external file.
- **Size**: Configurable, with a default size of 4KB (0xBFC00000 to 0xBFC00FFF), organized as byte-addressable storage.
- **Sequential Addressing**: Instructions are fetched based on the PC.

### Implementation Details

- **Input Ports**: clk, addr_i 
- **Output Ports**: instr_o
- **Memory Array**: Implemented as a ROM-style 2D array:

    ```systemverilog
    localparam MEM_SIZE = 4 * 1024;   // 4KB default size (0xBFC0 0000 to 0BFC0 0FFF) 
    logic [7:0] mem [0:MEM_SIZE-1];
    ```

- **Read Logic**: Combines four consecutive bytes into a 32-bit instruction based on the Program Counter:

    ```systemverilog
    instr_o = {mem[addr_i[11:0] + 3], mem[addr_i[11:0] + 2], mem[addr_i[11:0] + 1], mem[addr_i[11:0]]};
    ```

## Testing and Verification

### Testbench Setup

We developed two testbenches to validate both memories:

1. **[Data Memory](../tb/tests/instr_mem_tb.cpp)**: Verified read/write operations with different byte-enable configurations.
2. **[Instruction Memory](../tb/tests/data_mem_tb.cpp)**: Tested correct instruction fetching based on program counter values.

Evidence shown two memory works can be find separately from here: [data_mem testbench passes](../images/TestEvidence/data_mem_tests_passed.png), [instr_mem testbench passes](../images/TestEvidence/instr_mem_tests_passed.png).

## Conclusion

The Data Memory and Instruction Memory were successfully implemented and verified. Both modules comply with the RV32I specification, ensuring efficient memory access and instruction fetching for the processor.
