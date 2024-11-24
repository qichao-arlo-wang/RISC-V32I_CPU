#include "base_testbench.h"
#include <filesystem>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int tick = 0;
unsigned int CYCLES = 256;
int i;

class CpuTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->rst = 0;
        top->a0 = 0;
    }
};

void runSimulation(int cycles)
{
    for (tick = 0; tick < 2; tick++) {
        tfp->dump (2*i+tick);  // unit is in ps!!!
        top->clk = !top->clk;
        top->eval ();
    }
}

TEST_F(CpuTestbench, BaseProgramTest)
{
    bool success = false;
    system("pwd");
    std::filesystem::current_path("../");
    system("pwd");
    system("./compile.sh asm/program.S");

    for (i = 0; i < CYCLES; i++)
    {
        runSimulation(2);
        if (top->a0 == 254)
        {
            SUCCEED();
            success = true;
            break;
        }
    }
    if (!success)
    {
        FAIL() << "Counter did not reach 254";
    }
}

// Note this is how we are going to test your CPU. Do not worry about this for
// now, as it requires a lot more instructions to function
// TEST_F(CpuTestbench, Return5Test)
// {
//     system("./compile.sh c/return_5.c");
//     runSimulation(100);
//     EXPECT_EQ(top->a0, 5);
// }

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
