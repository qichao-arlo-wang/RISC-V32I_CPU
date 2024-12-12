# Things need to be noticed
- **USE THE RELATIVE PATH**
- Picture & Image for the pdf plotting on Vbuddy !!! video need to be updated
- Fill in / Edit the contribution table
- Add test command & explaination
- update repo struction diagram

# Group-9-RISC-V Team Project

## RISC-V RV32I Processor Pipeline
![pipeline structure](/images/pipeline_structure.jpg)


## Final submission

Our team has successfully completed and verified the following for our RV32I 
  processor:

| Tag                                                                                                  |
| ---------------------------------------------------------------------------------------------------- |
| [Lab4](https://github.com/arlo-wang/Group-9-RISC-V/blob/6446b802a61043c4c9276103159d4a91b70c46dc/team_statements/lab4.md.jpg)                                        | 
| [Single-Cycle(full RISC Design)](https://github.com/arlo-wang/Group-9-RISC-V/blob/6446b802a61043c4c9276103159d4a91b70c46dc/team_statements/single_cycle.md) | 
| [Pipeline](https://github.com/arlo-wang/Group-9-RISC-V/blob/6446b802a61043c4c9276103159d4a91b70c46dc/team_statements/pipeline.md)                                | 
| [Cache](https://github.com/arlo-wang/Group-9-RISC-V/blob/6446b802a61043c4c9276103159d4a91b70c46dc/team_statements/cache.md)                                 |


## Personal statements

| Member    | Personal statement |
|-----------|--------------------|
| Arlo     | [Personal statement](./personal_statements/arlo_wang.md) |
| Enxing   | [Personal statement](./personal_statements/enxing_lao.md) |
| Zecheng  | [Personal statement](./personal_statements/zecheng_zhu.md) |
| Zitong   | [Personal statement](./personal_statements/zitong_hon.md) |


## Quick Start

### Things to note before ANY test:
- makes sure you are in **tb** folder
- if u r testing with vbuddy, please configure vbuddy.cfg file and properly connect your vbuddy to your computer

### Using the testbench
The `pdf.sh` script allows you to load different `.mem` files depending on the user input. Each command automatically configures the data memory for the PDF testbench. Refer to the testbench documentation for further details. Use the following commands to specify the desired dataset:


| Command                               | Explanation                           |
| ------------------------------------- |-------------------------------------- |
| `./doit.sh verify.cpp`        | Test all instruction implemented      |
| `./doit.sh TEST FILE NAME`    | Test the entire instruction testbench |
| `./f1.sh test/TEST FILE NAME` | Test the F1 lights testbench (vBuddy) |
| `./pdf.sh gaussian`| Loads the `gaussian.mem` dataset.     |
| `./pdf.sh noisy`   | Loads the `noisy.mem` dataset.        |
| `./pdf.sh sine`    | Loads the `sine.mem` dataset.         |
| `./pdf.sh triangle`| Loads the `triangle.mem` dataset.     |


## Team Workflow

### Repo management (using `git`)

- The functions of `git` were fully utilised in this project
- `Branches` were created  to implement different functions to avoid conflict / overlap
- `Tags` were created for each completed version of the RV32I processor

### Folder Explaination 

- [`images`](images/): images for [`test evidence, schematic, to beadded`](docs/)
- [`rtl`](rtl/): RV32I processor modules
- [`tb`](tb/): Testbench and scripts

## Working Evidence

### Test result evidence
- [`test evidence`]((https://github.com/arlo-wang/Group-9-RISC-V/tree/main/images/TestEvidence))

### Graphs
| Dataset | Graph | Dataset | Graph |
|-|-|-|-|
| Gaussian | ![gaussian_graph](images/PATH for GRAPH) | Sine | ![sine_graph](images/PATH for GRAPH) |
| Triangle | ![triangle_graph](images/PATH for GRAPH) | Noisy | ![noisy_graph](images/PATH for GRAPH) |

### Videos

F1 lights

# video need to be updated

**<video controls src="./images/TestEvidence/f1testingvid.mp4"></video>**

Gaussian

**<video controls src="./images/TestEvidence/gaussian.mp4"></video>**

Sine

**![pdf_sine](./images/TestEvidence/sine.jpg)**

Triangle
**![pdf_triangle](./images/TestEvidence/triangle.jpg)**

Noisy

**<video control src="./images/TestEvidence/noisy.mp4"></video>**


## Team Contribution

- Work Contribution Table
- `*` (one star) refers to **minor contribution**
- `**` (two stars) refers to **major contribution**

|              |                                          | Arlo (arlo-wang)   | Enxing  git name | Zecheng Zhu (Keven Zhu & Zecheng)| Zitong (git name) |
| ------------ | ---------------------------------------- | ------------------ | ---------------- | -------------------------------- | ---------------- |
| Lab 4        | Program Counter                          |        **          |                  |                          |                  |
|              | ALU                                      |                    |                  |                       |                  |
|              | Register File                            |        **          |                  |                       |                  |
|              | Instruction Memory                       |        **          |                  |                          |              |
|              | Control Unit main_decoder                |                    |                  |                          |               |
|              | Control Unit alu_decoder                 |                    |                  |                          |               |
|              | Sign Extend                              |                    |                  |                          |              |
|              | Top                                      |        **          |                  |                          |                  |
|              | Testbench                                |        **          |                  |                          |                  |
| Single cycle | Data Memory                              |        **          |                  |                      |               |
|              | Program Counter (refactor)               |        **          |                  |                          |                  |
|              | ALU                                      |                    |                  |                          |              |
|              | Register File (refactor)                 |        **          |                  |                        |                  |
|              | Instruction Memory (refactor)            |        **          |               |                          |                  |
|              | Control Unit (refactor)                  |                    |                  |                       |             |
|              | Sign Extend (refactor)                   |                    |               |                          |                 |
|              | Unit Testbeches                          |        **          |               |                          |                  |
|              | Top                                      |        **          |               |                          |                  |
|              | F1 starting light program                |                    |               |                          |                  |
| Pipeline     | Pipeline flip-flop stages                |                    |                |                          |                  |
|              | Control unit (refactor)                  |                    |               |                          |                  |
|              | Hazard unit                              |                    |               |                          |                  |
|              | Top                                      |                    |               |                          |                  |
|              | Testbench                                |                    |               |                          |                  |
|              | PDF testing                              |                    |               |                          |                  |
| Instr Cache  | Main instruction memory (refactor)       |        **          |               |                          |                  |
|              | L1 four-way set associative instr_cache  |        **          |               |                       |                |
|              | L2 four-way set associative instr_cache  |        **          |               |                       |                |
|              | L3 eight-way set associative instr_cache |        **          |               |                       |                |
|              | Instruction memory top                   |        **          |               |                       |                |
| Data Cache   | Main instruction memory (refactor)       |        **          |               |                          |                  |
|              | L1 four-way set associative data_cache   |        **          |               |                       |                |
|              | L2 four-way set associative data_cache   |        **          |               |                       |                |
|              | L3 eight-way set associative data_cache  |        **          |               |                       |                |
|              | Data memory top                          |        **          |               |                       |                |
| Shell scripts| pdf.sh                                   |        **          |               |                          |                  |
|              | f1.sh                                    |        **          |               |                          |                  |
| Other extended works| Full RISCV instructions testing   |                    |               |                          |                  |
|              | FPGA                                     |        **          |               |                          |                  |

As a team, we all agree that the above table and commits do not accurately 
measure the contribution of team members due to the following reasons:

  1. When working together in Library / Student hub / meeting on Google Meet (online), some of us may working one of the laptops, so some commits made by team members are 
  often a combined effort of two or more members.

  2. The effort revolving around debugging is often highly overlooked - commits 
  with simple fixes often took hours / days of effort from two or more members 
  to debug a small mistake.

  3. Testbench building and writing played a huge role in streamlining our 
  process, and multiple tests were written to specifically do debugging and 
  isolate problematic parts / instructions.
