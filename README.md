# Group-9-RISC-V Team Project

## RISC-V RV32I Processor (Part 1)
  
![part 1 task allocation](/images/overall_structure.jpg)

- Arlo: blue part
- Zecheng: green part
- Zitong: pink part
- Enxing: testing

# RISC-V RV32I Processor
# THings needed
- Picture & Image for the pdf plotting on Vbuddy
- Fill in / Edit the contribution table
- Add test commant & explaination
- Add personal statement link
## Team 9 Statement

| Arlo Wang (repo master) | Enxing | Zecheng | Zitong |
|-|-|-|-|

## Final submission

Our team has successfully completed and verified the following for our RV32I 
  processor:

| Tag                                                                                                  | Statement |
| ---------------------------------------------------------------------------------------------------- |-------------------------------------------|
| [Lab4](https://github.com/arlo-wang/Group-9-RISC-V/tree/lab4)                                        | [lab4.md](link) | 
| [Single-Cycle(full RISC Design)](https://github.com/arlo-wang/Group-9-RISC-V/tree/full-rv32i-design) | [single_cycle_full_design.md](link) |
| [Pipeline](https://github.com/arlo-wang/Group-9-RISC-V/tree/pipeline)                                | [pipeline.md](link) |
| [Cache](https://github.com/arlo-wang/Group-9-RISC-V/tree/data_cache)                                 | [cache.md](link) |


## Personal statements

| Member    | Personal statement |
|-----------|--------------------|
| Arlo     | [Personal statement](/personal_statements/?.md) |
| Enxing   | [Personal statement](/personal_statements/?.md) |
| Zecheng  | [Personal statement](/personal_statements/?.md) |
| Zitong   | [Personal statement](/personal_statements/?.md) |


## Quick Start

Note: before **ANY** test (including the first time script), execute this command.

```bash
cd tb
```


### Using the testbench


| Command                               | Explanation                           |
| ------------------------------------- |-------------------------------------- |
| `./doit.sh`                           | Test all.                             |
| `./doit.sh TEST FILE NAME`            | Test the entire instruction testbench |
| `./doit.sh test/TEST FILE NAME`       | Test the F1 lights testbench (stdout) |
| `./doit.sh test/TEST FILE NAME`       | Test the F1 lights testbench (vBuddy) |
| `./doit.sh test/TEST FILE NAME`       | Test the PDF testbench* (stdout)      |
| `./doit.sh test/TEST FILE NAME`       | Test the PDF testbench* (vBuddy)      |

* may add specifc command

\* Note: to run the PDF testbench, you need to load the data memory. 
Run only ONE of the following commands BEFORE `doit.sh`.

Gaussian:

```bash
 Specific command
```

Noisy:

```bash
 Specific command
```

Sine:

```bash
 Specific command
```

Triangle:

```bash
 Specific command
```


```bash
# Must be ttyUSB0 - otherwise find and replace in vbuddy.cpp
To be updated
```

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


### Graphs
| Dataset | Graph | Dataset | Graph |
|-|-|-|-|
| Gaussian | ![gaussian_graph](images/PATH for GRAPH) | Sine | ![sine_graph](images/PATH for GRAPH) |
| Triangle | ![triangle_graph](images/PATH for GRAPH) | Noisy | ![noisy_graph](images/PATH for GRAPH) |

### Videos

F1 lights

**PATH for Video**

Gaussian

**PATH for Video**

Sine

**PATH for Video**

Triangle
**PATH for Video**

Noisy

**PATH for Video**


## Team Contribution

- Work Contribution Table
- `*` (one star) refers to **minor contribution**
- `**` (two stars) refers to **major contribution**

|              |                               | Arlo (git name)    | Enxing  git name | Zecheng Zhu (Keven Zhu & Zecheng)| Zitong (git name) |
| ------------ | ----------------------------- | ------------------ | ---------------- | -------------------------------- | ---------------- |
| Lab 4        | Program Counter               |                  |                  |                          |                  |
|              | ALU                           |                    |                  |                       |                  |
|              | Register File                 |                    |                  |                       |                  |
|              | Instruction Memory            |                    |                  |                          |              |
|              | Control Unit main_decoder                 |                    |                  |                          |               |
|              | Control Unit alu_decoder                 |                    |                  |                          |               |
|              | Sign Extend                   |                    |                  |                          |              |
|              | Testbench                     |                    |               |                          |                  |
| Single Cycle | Data Memory                   |                  |                  |                      |               |
|              | Program Counter (refactor)    |                    |               |                          |                  |
|              | ALU (refactor)                |                    |               |                          |              |
|              | Register File (refactor)      |                    |                  |                        |                  |
|              | Instruction Memory (refactor) |                 |               |                          |                  |
|              | Control Unit (refactor)       |                 |                |                       |             |
|              | Sign Extend (refactor)        |                    |               |                          |                 |
| Pipeline     | Pipeline register     |                 |                |                          |                  |
|              | Hazard unit                   |                |               |                          |                  |
| Cache        | Memory (refactor)             |                 |               |                          |                  |
|              | Direct mapped cache           |                |               |                       |                |
|              | Two-way set associative cache |                 |              |                       |                |

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
