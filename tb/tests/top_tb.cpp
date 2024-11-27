#include "Vtop.h"              // Verilated top module header
#include "verilated.h"         // Verilator library
#include <iostream>

//for addi
// Simulation time
vluint64_t sim_time = 0;

int main() {
    // Initialize Verilator
    Verilated::commandArgs(0, (const char**)nullptr);
    Vtop* dut = new Vtop;

    // Reset sequence
    dut->rst = 1;
    dut->clk = 0;
    dut->eval();
    sim_time += 5;
    dut->rst = 0;

    // Load registers with initial values
    // Let's assume x1 holds 5, and we want to perform x3 = x1 + 10
    dut->top__DOT__reg_file_inst__DOT__reg_file[10] = 5;   // rs1 (x1) = 5
    //dut->top__DOT__instruction_memory_inst__DOT__mem[0] = 0x00508213; // addi x4, x1, 10

    // Run simulation for a few clock cycles
    for (int i = 0; i < 20; i++) {
        dut->clk = !dut->clk;  // Toggle clock
        dut->eval();
        sim_time += 5;

        std::cout << "Time: " << sim_time
            << " - PC: " << dut->top__DOT__pc
            << " - a0: " << dut->a0
            << std::endl;

    }

    // Check results
    if (dut->a0 == 15) {  // 5 + 10 = 15
        std::cout << "ADDI Test Passed!" << std::endl;
    } else {
        std::cout << "ADDI Test Failed!" << std::endl;
    }

    // Cleanup
    delete dut;
    return 0;
}

//for bne
// #include "Vtop.h"
// #include "verilated.h"
// #include <iostream>

// vluint64_t sim_time = 0;

// int main() {
//     Verilated::commandArgs(0, nullptr);
//     Vtop* dut = new Vtop;

//     // Reset sequence
//     dut->rst = 1;
//     dut->clk = 0;
//     dut->eval();
//     sim_time += 5;
//     dut->rst = 0;

//     // Load registers for BNE test
//     dut->top__DOT__reg_file_inst__DOT__regfile[1] = 5;   // rs1 = 5
//     dut->top__DOT__reg_file_inst__DOT__regfile[2] = 10;  // rs2 = 10
    
//     // Load BNE instruction (if rs1 != rs2, branch)
//     dut->top__DOT__instruction_memory_inst__DOT__mem[0] = 0x0020c663; // bne x1, x2, 12

//     // Run simulation
//     for (int i = 0; i < 20; i++) {
//         dut->clk = !dut->clk;  // Toggle clock
//         dut->eval();
//         sim_time += 5;

//         // Print state
//         std::cout << "Time: " << sim_time 
//                   << " - PC: " << dut->top__DOT__pc 
//                   << std::endl;
//     }

//     // Check if branch taken (depends on testbench logic)
//     std::cout << "BNE Test Completed." << std::endl;

//     // Cleanup
//     delete dut;
//     return 0;
// }
