#include "testbench.h"
#include "../vbuddy.cpp"
#include <unistd.h> //usleep()

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
        top->trigger = 1;  // Enable trigger just once at the start (if needed by your design)
    }
};

TEST_F(CpuTestBench, StartBuddy) {
    int max_cycles = 100000;

    // No random seed needed here, as randomness is handled by assembly LFSR now.

    if (vbdOpen() != 1) {
        SUCCEED() << "Vbuddy not available.";
    }
    vbdHeader("F1_Lights");

    for (int i = 0; i < max_cycles; ++i) {
        // The CPU assembly code will control a0 (lights on/off) and handle delays.
        // We just run the simulation and display the value of a0.
        
        // Update Vbuddy bar with a0 value
        vbdBar(top->a0 & 0xFF);

        // Run a single simulation cycle
        runSimulation();
    }
    SUCCEED();
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}