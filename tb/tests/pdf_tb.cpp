#include "testbench.h"
#include "../vbuddy.cpp"
#include <iostream>
#include <cstdlib>

#define MAX_SIM_CYC 1000000
// #define DISPLAY_LOOP_PC 0x58  

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class CpuTestBench : public Testbench {
protected:
    void initializeInputs() override {
        top->clk = 0;
        top->rst = 1;  // Assert reset

        runSimulation(5);  // Run for 5 cycles
        top->rst = 0;  // De-assert reset
        top->trigger = 1;  // Enable trigger
    }
};

TEST_F(CpuTestBench, StateTest) { 
    // Initialize VBuddy with a header
    if (vbdOpen() != 1) {
        std::cerr << "VBuddy failed to open. Exiting." << std::endl;
        exit(EXIT_FAILURE);
    }   
    vbdHeader("PDF TEST");

    bool pdf_build_done = false;
    for (int i = 0; i < MAX_SIM_CYC; ++i) {
        runSimulation(1);
        
        //// Debugging PC and Instruction
        // std::cout << "Cycle: " << ticks 
        //           << " | PC: 0x" << std::hex << top->pc
        //           << " | Instr: 0x" << top->instr 
        //           << " | A0: 0x" << top->a0
        //           << std::dec << std::endl;

        // Only plot after PDF build is complete
        if (top->a0 != 0) {
            vbdPlot(int(top->a0), 0, 255);
        }

        if (vbdGetkey() == 'q')
            exit(0);
    }

    vbdClose();
    SUCCEED();
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
