#include "base_testbench.h"


Vdut *top;
VerilatedVcdC *tfp;
unsigned int main_time = 0;

class InstrMemSysTestbench : public BaseTestbench
{
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
};

// first normal test case
TEST_F(InstrMemSysTestbench, InstrMemWorksTest1) {
    initializeInputs();
    top->addr_i = 0xBFC00000;
    top->eval();
    toggleClock();

    // Expected instruction from original instr_mem tests
    EXPECT_EQ(top->instr_o, 0x0ff00313);
}

// second normal test case
TEST_F(InstrMemSysTestbench, InstrMemWorksTest2) {
    initializeInputs();
    top->addr_i = 0xBFC00004;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->instr_o, 0x00000513);
}

// third normal test case
TEST_F(InstrMemSysTestbench, InstrMemWorksTest3) {
    initializeInputs();
    top->addr_i = 0xBFC00008;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->instr_o, 0x00000593);
}

// unaligned memory access test case
TEST_F(InstrMemSysTestbench, UnalignedMemAccessTest) {
    initializeInputs();
    top->addr_i = 0xBFC00002; // Unaligned address
    top->eval();
    toggleClock();
    
    // Expect a default instruction (0xDEADBEEF) on unaligned
    EXPECT_EQ(top->instr_o, 0xDEADBEEF);
}

// out-of-range memory access test case
TEST_F(InstrMemSysTestbench, OutOfRangeMemAccessTest) {
    initializeInputs();
    top->addr_i = 0xBFC01000; // Out-of-range address
    top->eval();
    toggleClock();

    // Expect 0xDEADBEEF on out-of-range
    EXPECT_EQ(top->instr_o, 0xDEADBEEF);
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("Vdut.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
