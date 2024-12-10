#include "base_testbench.h"
#include <verilated_vcd_c.h>

#define DEADBEEF 0xDEADBEEF

Vdut *top;
VerilatedVcdC *tfp;

class InstrMemSysTestbench : public BaseTestbench {
protected:
    void initializeInputs() override {
        top->clk = 0;
        top->addr_i = 0;
        top->main_mem_instr = DEADBEEF;
    }

    void simulateClockCycle(int cycles) {
        for (int i = 0; i < cycles; i++) {
            top->clk = 1;
            top->eval();
            top->clk = 0;
            top->eval();
        }
        
    }
};

TEST_F(InstrMemSysTestbench, TestL1CacheHit) {
    initializeInputs();

    // First access: miss
    top->addr_i = 0xBFC00000;
    top->main_mem_instr = 0x0FF00313;
    simulateClockCycle(5);
    EXPECT_EQ(top->cache_hit_l1, 0);
    EXPECT_EQ(top->cache_hit_l2, 0);
    EXPECT_EQ(top->cache_hit_l3, 0);

    // Second access: hit in L1
    simulateClockCycle(5);
    EXPECT_EQ(top->cache_hit_l1, 1);
    EXPECT_EQ(top->cache_hit_l2, 0);
    EXPECT_EQ(top->cache_hit_l3, 0);
    EXPECT_EQ(top->instr_o, 0x0FF00313);
}

TEST_F(InstrMemSysTestbench, TestL2CacheHit) {
    initializeInputs();

    top->addr_i = 0xBFC00004; // Address that should hit L2 cache
    top->main_mem_instr = 0x00000513;
    simulateClockCycle(5);
    
    EXPECT_EQ(top->cache_hit_l1, 0);
    EXPECT_EQ(top->cache_hit_l2, 1);
    EXPECT_EQ(top->cache_hit_l3, 0);
    EXPECT_EQ(top->instr_o, 0x00000513);
}

TEST_F(InstrMemSysTestbench, TestL3CacheHit) {
    initializeInputs();

    top->addr_i = 0xBFC00008; // Address that should hit L3 cache
    top->main_mem_instr = 0x00000593;
    simulateClockCycle(5);

    EXPECT_EQ(top->cache_hit_l1, 0);
    EXPECT_EQ(top->cache_hit_l2, 0);
    EXPECT_EQ(top->cache_hit_l3, 1);
    EXPECT_EQ(top->instr_o, 0x00000593);
}

TEST_F(InstrMemSysTestbench, TestL3CacheMiss) {
    initializeInputs();

    top->addr_i = 0xBFC01000; // Address that should miss all caches
    top->main_mem_instr = DEADBEEF;
    simulateClockCycle(5);

    EXPECT_EQ(top->cache_hit_l1, 0);
    EXPECT_EQ(top->cache_hit_l2, 0);
    EXPECT_EQ(top->cache_hit_l3, 0);
    EXPECT_EQ(top->instr_o, DEADBEEF);
}

int main(int argc, char **argv) {
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    if (!tfp->isOpen()) {
        std::cerr << "Error: Could not open VCD file." << std::endl;
        exit(1);
    }
    tfp->open("instr_cache_waveform.vcd");
    tfp->close();
    delete tfp;
}
