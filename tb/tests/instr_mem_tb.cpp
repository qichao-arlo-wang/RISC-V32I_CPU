#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class InstrMemTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->addr = 0;
    }
};

// first normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest1)
{
    top->addr = 0;
    top->eval();

    EXPECT_EQ(top->instr, 0x1303f00f);
}

// second normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest2)
{
    top->addr = 4;
    top->eval();

    EXPECT_EQ(top->instr, 0x13050000);
}

// third normal test case
TEST_F(InstrMemTestbench, InstrMemWorksTest3)
{
    top->addr = 8;
    top->eval();

    EXPECT_EQ(top->instr, 0x93050000);
}

// unaligned memory access test case
TEST_F(InstrMemTestbench, UnalignedMemAccessTest)
{
    top->addr = 2; // Unaligned address
    top->eval();
    
    // Expect a default NOP instruction (0x00000013) to be returned
    EXPECT_EQ(top->instr, 0x00000013);
}

// out-of-range memory access test case
TEST_F(InstrMemTestbench, OutOfRangeMemAccessTest)
{
    // Set address to a value that exceeds MEM_SIZE
    top->addr = 256 * 4; // MEM_SIZE = 256, so this is out of range
    top->eval();
    
    // Expect the instruction to be the default NOP instruction (0x00000013)
    EXPECT_EQ(top->instr, 0x00000013) << "Out-of-range memory access did not return the expected NOP instruction.";
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
