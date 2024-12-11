#include "testbench.h"
#include "../vbuddy.cpp"
#include <cstdlib>
#include <ctime>
#include <unistd.h> //unsleep()

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
    int max_cycles = 100000;

    srand(time(0)); //generate random num

    if (vbdOpen() != 1) {
        SUCCEED() << "Vbuddy not available.";
    }
    vbdHeader("F1_Lights");

    bool light_on = false;
    int random_off_timer = 0;

    for (int i = 0; i < max_cycles; ++i) {
        if (!light_on){
            top->trigger = 1; //lights on
            light_on = true;
            random_off_timer = rand() % 200 + 50; //random timer
        } else if (light_on && random_off_timer > 0){
            random_off_timer--;
        } else { 
            top->trigger = 0; //lights off
            light_on = false;
        }

        // Update Vbuddy bar with a0 value
        vbdBar(top->a0 & 0xFF);
        // Run a single simulation cycle
        runSimulation();
        usleep(100000); //delay between each simulation
    }
    SUCCEED();
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}

