#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int main_time = 0;

class InstrMemSysTestbench : public BaseTestbench {
protected:
    void initializeInputs() override {
        top->clk = 0;
        top->addr_i = 0;
    }

    void toggleClock() {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time++;
    }

    void simulateClockCycle(int num_cycles) {
        for (int i = 0; i < num_cycles; i++) {
            toggleClock();
            toggleClock();
        }
    }
};

TEST_F(InstrMemSysTestbench, InstrMemTest) {
    initializeInputs();

    // Test with multiple addresses
    uint32_t addresses[] = {0xBFC00000, 0xBFC00004, 0xBFC00008};
    uint32_t expected_instr[] = {0x0ff00313, 0x00000513, 0x00000593};

    for (int i = 0; i < 3; i++) {
        top->addr_i = addresses[i];
        simulateClockCycle(5); // Run clock cycles to simulate instruction fetching

        EXPECT_EQ(top->instr_o, expected_instr[i]);

        std::cout << "ADDR: " << std::hex << top->addr_i
                  << ", CACHE_HIT: " << (int)top->cache_hit_o
                  << ", INSTR: " << std::hex << top->instr_o << std::endl;
    }
}

int main(int argc, char **argv) {
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("instr_mem_sys_waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
