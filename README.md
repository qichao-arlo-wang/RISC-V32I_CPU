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

# Arlo Matchmaking - Team Contributions and Work Breakdown

## Team Members and GitHub Handles
| Team Member   | GitHub Handle  |
|---------------|----------------|
| Arlo          | arlo-wang      |
| Keven         | zzczjh9        |
| En Xing       | lex734         |
| Zi Tong       | zth2           |

---

## Task Assignments

| Lab 4                    | Arlo | Keven | En Xing | Zi Tong |
|--------------------------|------|-------|---------|---------|
| Program Counter          |  *   |       |         |         |
| ALU                      |      |       |         |    *    |
| MUX                      |      |       |         |    *    |
| Register File            |  *   |       |         |    *    |
| Instruction Memory       |  *   |       |         |         |
| Control Unit             |      |   *   |    *    |         |
| Sign Extend              |      |   *   |         |         |
| Testbench                |  *   |       |    *    |         |
| Top                      |  *   |       |    *    |         |
| Single Cycle:            |                                  |
| Data Memory              |  *   |       |         |         |
| Program Counter (refactor)|  *  |   *   |    *    |         |
| ALU (refactor)            |     |   *   |         |    *    |
| Register File (refactor)  |   * |       |         |         |
| Instruction Memory (refactor)|  |       |         |         |
| Control Unit (refactor)   |     |   *   |      *  |         |
| Sign Extend (refactor)    |     |  *    |         |         |
| Top                       |  *  |       |   *     |         |
| Unit Test benches         |   * |       |         |     *   |
| F1 Starting Light program |     |       |         |     *   |
| PDF Testing               |     |       |         |     *   |
| Pipeline:                 |                                 |
| Pipeline Flip-Flop Stages |     |   *   |    *    |         |
| Control unit (refactor)   |     |   *   |    *    |         |
| Hazard Unit               |     |   *   |    *    |         |
| Top                       |     |   *   |    *    |         |
| PDF Testing               |     |   *   |    *    |    *    |
| Instruction Cache:        |                                 |
| Main Instruction memory (refactor)|  *  |    |    |    *    |
| L1 Four-Way Set Associative|   *   |      |       |     *   |
| L2 Four-Way Set Associative|   *   |      |       |    *    |
| L3 Eight-Way Set Associative|  *   |      |       |    *    |
| Instruction Memory Top      |   *  |      |       |     *   |
| Data Cache:                |                                 |
| Main data memory (refactor)|  * |       |         |         |
| L1 Four-Way Set Associative | * |       |         |         |
| L2 Four-Way Set Associative | * |       |         |         |
| L3 Eight-Way Set Associative| * |       |         |         |
| Data Memory Top             | * |       |         |         |
| Shell scripts:            |                                 |
| `pdf.sh`                  |  *  |       |         |    *    |
| `f1.sh`                   |     |       |         |    *    |
| Extended Work:            |                                 |
| Full RISC-V Instructions Testing|   |  * |     *  |         |
| Instruction Cache         |      |       |        |   *     |
| FPGA Implementation       |      |   *   |        |         |

---


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
