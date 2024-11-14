#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class RegfileTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->we = 0;
        top->rs1 = 0;
        top->rs2 = 0;
        top->rd = 0;
        top->wd = 0;
    }

    void runSimulation()
    {
        for (int clk = 0; clk < 2; clk++)
        {
            top->eval();
            tfp->dump(2 * ticks + clk);
            top->clk = !top->clk;
        }
        ticks ++;

        if (Verilated::gotFinish())
        {
            exit(0);
        }
    }
};

TEST_F(RegfileTestbench, writeRegfiletest)
{
    while (clk < 10000) {

        if (clk)
    }
}