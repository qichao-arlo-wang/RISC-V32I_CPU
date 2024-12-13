# to do list:
- update the branch link after we change the default branch
- add a table for the team_statement
- update team contribution table

# Group-9-RISC-V Team Project

## Joint statement

Our team successfully completed a **full RV32I design**, implementing **all base RV32I instructions** except for FENCE, ECALL/EBREAK, and CSR instructions. We carried out thorough ASM testing on the newly added instructions, implemented a **pipeline with hazard handling**, and developed **4-way and 8-way L1, L2, and L3 data and instruction caches**. Finally, we made significant efforts to deploy our design on an **FPGA**, and although we were unable to fully achieve success, we learned a great deal through the process.

Our project is mainly organized into three branches, each representing a significant milestone in our RISC-V processor design:

**//////// update the branch link after we change the default branch //////////**

1. [**main branch**]():
   
   This branch builds upon the foundation of Lab4. It implements a single-cycle version of the full RV32I design without including any pipelining and cache structures.

2. [**pipeline branch**](https://github.com/arlo-wang/Group-9-RISC-V/tree/pipeline)：
   
   This branch focuses on the pipeline implementation. It successfully integrates all RV32I instructions with hazard handling. A conceptural [diagram](/images/pipeline_structure.jpg) is also provided for reference

3. [**full-rv32i-design branch**]():
   
   This branch contains the complete implementation of the full RV32I design, incorporating all the features mentioned above, including the pipeline with hazard handling, 4-way and 8-way L1, L2 and L3 instruction and data caches.

In addition to these main branches, you can also find other branches on our GitHub repository, including [lab4](https://github.com/arlo-wang/Group-9-RISC-V/tree/lab4), [data_cache](https://github.com/arlo-wang/Group-9-RISC-V/tree/data_cache), [data-cache-multilevel](https://github.com/arlo-wang/Group-9-RISC-V/tree/data-cache-multilevel), [instr_cache](https://github.com/arlo-wang/Group-9-RISC-V/tree/instr_cache) and [instr-cache-multilevel](https://github.com/arlo-wang/Group-9-RISC-V/tree/instr_cache_multilevel). Each of these branches was created to implement specific functionalities, such as data and instruction caches or to track progress from earlier stages of development.


## Personal statements

| Member    | Personal statement |
|-----------|--------------------|
| Arlo     | [Personal statement](./personal_statements/arlo_wang.md) |
| Enxing   | [Personal statement](./personal_statements/enxing_lao.md) |
| Zecheng  | [Personal statement](./personal_statements/zecheng_zhu.md) |
| Zitong   | [Personal statement](./personal_statements/zitong_hon.md) |

## Quick Start

### Things to note before ANY test:

- Please makes sure that you are in the `tb` folder
- If you are testing with vBuddy, ensure that the `vbuddy.cfg` file is correctly configured and that your vBuddy is properly connected to your computer.
- For **Windows users**, you may need to run `./attach_usb.sh` to correctly set up the USB connection.

### Using the testbench

The `pdf.sh` script allows you to load different `.mem` files depending on the user input. Each command automatically configures the data memory for the PDF testbench. Refer to the testbench documentation for further details. Use the following commands to specify the desired dataset:


| Command                               | Explanation                           |
| ------------------------------------- |-------------------------------------- |
| `./doit.sh verify.cpp`                | Test all instruction implemented      |
| `./pdf.sh gaussian`                   | Loads the `gaussian.mem` dataset.     |
| `./pdf.sh noisy`                      | Loads the `noisy.mem` dataset.        |
| `./pdf.sh sine`                       | Loads the `sine.mem` dataset.         |
| `./pdf.sh triangle`                   | Loads the `triangle.mem` dataset.     |
| `./f1.sh`                             | Test the F1 lights testbench (vBuddy) |

## Working Evidence

### Test result evidence

- [`test evidence`](./images/TestEvidence/)

### PDF & F1 videos

| Dataset | Videos | Dataset | Videos |
|-|-|-|-|
| Gaussian | [gaussian_vbuddy](./images/TestEvidence/gaussian.mp4) | Sine | [sine_vbuddy](./images/TestEvidence/sine.jpg) |
| Triangle | [triangle_vbuddy](./images/TestEvidence/triangle.jpg) | Noisy| [noisy_vbuddy](./images/TestEvidence/noisy.mp4) |
| F1 light | [F1_vbuddy](./images/TestEvidence/f1_light.mp4)


## Team Contribution Table

- Work Contribution Table
- `*` (one star) refers to **minor contribution**
- `**` (two stars) refers to **major contribution**

|              |                                          | Arlo (arlo-wang)   | Enxing (lex734) | Zecheng Zhu (Keven Zhu & Zecheng)| Zitong (zth2) |
| ------------ | ---------------------------------------- | :----------------: | :-------------: | :------------------------------: | :------------: |
| Lab 4        | Program Counter                          |        **          |                 |                *                 |                |
|              | ALU                                      |                    |                 |                **                |        *       |
|              | Register File                            |        **          |                 |                                  |        *       |
|              | Instruction Memory                       |        **          |                 |                                  |                |
|              | Control Unit main_decoder                |                    |                 |                **                |                |
|              | Control Unit alu_decoder                 |                    |                 |                **                |                |
|              | Sign Extend                              |                    |                 |                **                |                |
|              | Top                                      |        **          |                 |                                  |                |
|              | Testbench                                |        **          |                 |                                  |                |
| Single cycle | Data Memory                              |        **          |                 |                                  |        *       |
|              | Program Counter (refactor)               |        **          |                 |                *                 |                |
|              | ALU                                      |                    |                 |                **                |        *       |
|              | Register File (refactor)                 |        **          |                 |                                  |        *       |
|              | Instruction Memory (refactor)            |        **          |                 |                                  |                |
|              | Control Unit main_decoder (refactor)     |                    |                 |                **                |                |
|              | Control Unit alu_decoder (refactor)      |                    |                 |                **                |                |
|              | Sign Extend (refactor)                   |                    |                 |                **                |                |
|              | Unit Testbeches                          |        **          |                 |                                  |        *       |
|              | Top                                      |        **          |                 |                                  |                |
|              | F1 starting light program                |                    |                 |                **                |       **       |
| Pipeline     | Pipeline flip-flop stages                |                    |                 |                **                |                |
|              | Control unit (refactor)                  |                    |        **       |                                  |                |
|              | Hazard unit                              |                    |        **       |                **                |                |
|              | Top                                      |                    |        **       |                **                |                |
|              | Testbench                                |                    |        **       |                                  |                |
|              | PDF testing                              |                    |        **       |                **                |       **       |
| Instr Cache  | Main instruction memory (refactor)       |        **          |                 |                                  |       **       |
|              | L1 four-way set associative instr_cache  |        **          |                 |                                  |       **       |
|              | L2 four-way set associative instr_cache  |        **          |                 |                                  |       **       |
|              | L3 eight-way set associative instr_cache |        **          |                 |                                  |       **       |
|              | Instruction memory top                   |        **          |                 |                                  |       **       |
| Data Cache   | Main instruction memory (refactor)       |        **          |                 |                                  |                |
|              | L1 four-way set associative data_cache   |        **          |                 |                                  |                |
|              | L2 four-way set associative data_cache   |        **          |                 |                                  |                |
|              | L3 eight-way set associative data_cache  |        **          |                 |                                  |                |
|              | Data memory top                          |        **          |                 |                                  |                |
| Shell scripts| pdf.sh                                   |        **          |                 |                *                 |       **       |
|              | f1.sh                                    |        **          |                 |                *                 |       **       |
| Other extended works| Full RISCV instructions testing   |                    |                 |                *                 |                |
|              | FPGA                                     |        **          |                 |                **                |                |

## File structure

```
.
├── README.md
├── images/
│   ├── TestEvidence/
├── personal_statements/
│   ├── arlo_wang.md
│   ├── enxing_lao.md
│   ├── zecheng_zhu.md
│   └── zitong_hon.md
├── rtl/
├── structure.md
├── tb/
│   ├── asm/
│   ├── reference/
│   ├── tests/
│   ├── assemble.sh
│   ├── attach_usb.sh
│   ├── compile.sh
│   ├── doit.sh
│   ├── f1.sh
│   ├── pdf.sh
│   ├── vbuddy.cfg
│   ├── vbuddy.cpp
│   └── verification.md
└── team_statements/
  ├── cache.md
  ├── lab4.md
  ├── pipeline.md
  ├── single_cycle.md
  └── testing.md
```

-----

As a team, we all agree that the above table and commits do not accurately measure the contribution of team members due to the following reasons:

  1. When working together in Library / Student hub / meeting on Google Meet (online), some of us may working one of the laptops, so some commits made by team members are often a combined effort of two or more members.

  1. The effort revolving around debugging is often highly overlooked - commits with simple fixes often took hours / days of effort from two or more members to debug a small mistake.

  1. Testbench building and writing played a huge role in streamlining our process, and multiple tests were written to specifically do debugging and isolate problematic parts / instructions.
