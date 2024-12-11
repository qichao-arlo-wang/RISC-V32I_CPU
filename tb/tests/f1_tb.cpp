#include "testbench.h"
#include "../vbuddy.cpp"


#define MAX_SIM_CYC 100000

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

TEST_F(CpuTestBench, StartBuddy) {

    if (vbdOpen() != 1) {
        SUCCEED() << "Vbuddy not available.";
    }
    vbdHeader("F1_Lights");

    for (int i = 0; i < MAX_SIM_CYC; ++i) {
        // //Print debug information
        // std::cout << "Cycle: " << i
        //           << " | PC: " << std::hex << top->pc
        //           << " | Instruction: " << std::hex << top->instr
        //           << " | a0: " << std::hex << top->a0
        //           << std::endl;

        // Update Vbuddy bar with a0 value
        vbdBar(top->a0 & 0xFF);

        // Run a single simulation cycle
        runSimulation();

        // Sleep to sync with Vbuddy updates
        //sleep(1);
    }
    SUCCEED();
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}

