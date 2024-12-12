# Single Cycle Processor Implementation

## Introduction

As part of our team project, we developed the `single cycle processor` as an extension of `lab 4`. The main challenge was to ensure correct implementation of the base RISC-V instruction set. Among the components, the `control unit` proved to be the most intricate, requiring significant debugging and teamwork to achieve full functionality.

---

## System Design and Decisions

### Data Memory

Our `data memory` module supports essential read and write functionalities, making it a critical component for program execution. Here are its main features:

- **Memory Initialization**: Data is pre-loaded from `data.hex` into a 128KB memory space starting at `0x0001_0000`.
- **Write Logic**: Supports byte (8-bit), half-word (16-bit), and word (32-bit) accesses controlled by the `byte_en` signal.
- **Read Logic**: Outputs memory values asynchronously based on the access type.

Relevant code:

```systemverilog
// Write Logic
always_ff @(posedge clk) begin
    if (wr_en_i) begin
        case (byte_en_i)
            4'b0001: mem[addr_i] <= wr_data_i[7:0]; // Byte
            4'b0011: begin                           // Half-word
                mem[addr_i]   <= wr_data_i[7:0];
                mem[addr_i+1] <= wr_data_i[15:8];
            end
            4'b1111: begin                           // Word
                mem[addr_i]   <= wr_data_i[7:0];
                mem[addr_i+1] <= wr_data_i[15:8];
                mem[addr_i+2] <= wr_data_i[23:16];
                mem[addr_i+3] <= wr_data_i[31:24];
            end
        endcase
    end
end

// Read Logic
always_comb begin
    case (byte_en_i)
        4'b0001: rd_data_o = {24'b0, mem[addr_i]};
        4'b0011: rd_data_o = {16'b0, mem[addr_i+1], mem[addr_i]};
        4'b1111: rd_data_o = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};
        default: rd_data_o = 32'hDEADBEEF;
    endcase
end
```

### Adder Module

The `adder` module computes the sum of two 32-bit inputs, which is essential for calculating the next program counter value or any arithmetic additions in the data path.

Relevant code:

```systemverilog
module adder (
    input  logic [31:0] in1_i,     // First input 
    input  logic [31:0] in2_i,     // Second input

    output logic [31:0] out_o      // Result of addition
);

    assign out_o = in1_i + in2_i;

endmodule
```

### Control Unit

The `control unit` orchestrates the overall functionality of the processor by managing the flow of data and controlling the operations of other components. Its main features include:

- **Decoders**: The `main_decoder` handles signal generation based on opcodes, while the `alu_decoder` interprets ALU control signals.
- **Branch Conditions**: Evaluates conditions such as `beq`, `bne`, `blt`, and `bge` using the ALU result and zero flag.
- **Program Counter Source**: Decides whether the next instruction is sequential or a branch target.

Relevant code:

```systemverilog
// Branch Condition Evaluation
always_comb begin
    case (funct3_i)
        3'b000: branch_condition = zero_i;                      // beq
        3'b001: branch_condition = ~zero_i;                     // bne
        3'b100: branch_condition = (alu_result_i < 0);          // blt
        3'b101: branch_condition = zero_i | (alu_result_i > 0); // bge
        default: branch_condition = 1'b0;
    endcase
end

// Program Counter Source Decision
always_comb begin
    case (opcode_i)
        7'b1100111, 7'b1101111: pc_src_o = branch; // JALR, JAL
        default: pc_src_o = branch & branch_condition;
    endcase
end
```

---

## Verification and Testing

To ensure accuracy and reliability, our team developed comprehensive testbenches for each module. These testbenches helped us isolate and fix issues efficiently.

### Tested Components

| Component         | Testbench Link                              |
|--------------------|---------------------------------------------|
| ALU Decoder           | [alu_decoder_tb.cpp](tb/tests/alu_decoder_tb.cpp)      |
| Control Unit       | [control_unit_tb.cpp](tb/tests/control_unit_tb.cpp) |
| Data Memory        | [data_mem_tb.cpp](tb/tests/data_mem_tb.cpp) |
| Instruction Memory | [instr_mem_tb.cpp](tb/tests/instr_mem_tb.cpp) |
| MUX               | [mux_tb.cpp](tb/tests/mux_tb.cpp)      |
| PC                | [pc_reg_tb.cpp](tb/tests/reg_tb.cpp) |
| Adder             | [adder_tb.cpp](tb/tests/adder_tb.cpp)  |
| Sign extension    | [sign_exten_tb.cpp](tb/tests/sign_exten_tb.cpp) |
| Register file     | [register_file_tb.cpp](tb/tests/register_file_tb.cpp) |
### Example Testbench Snippet

Here is an example from the `control unit` testbench:

```cpp
TEST_F(ControlunitTestbench, MemWriteTest)
{   
    top->instr = OPCODE_S;
    top->eval();

    EXPECT_EQ(top->MemWrite, 1) << "Opcode = OPCODE_S";

    for (int opcode : { 
        OPCODE_I1, OPCODE_I2, OPCODE_I3, OPCODE_I4, 
        OPCODE_U1, OPCODE_U2, OPCODE_J, OPCODE_R, OPCODE_J
    }) {
        top->instr = opcode;
        top->eval();

        EXPECT_EQ(top->MemWrite, 0) << "Opcode: " << std::bitset<7>(opcode);
    }
}
```

### Results and Insights

The testbenches provide real-time feedback, displayed in the terminal using GTest framework. For example:

![GTest running in terminal](images/TestEvidence/control_unit_passed.png)

### Tools Used

We automated our testing, assembly and compilation using scripts:
- [`compile.sh`](tb/compile.sh): Compiles all test files.
- ['assemble.sh](tb/assemble.sh): Assemble files in assembly code.
- [`doit.sh`](tb/doit.sh): Runs the entire suite of tests.
- [`doit.sh verify.cpp`](tb/doit.sh): Runs only the assembly language program that verifies each RISCV instruction in (tb/asm).

