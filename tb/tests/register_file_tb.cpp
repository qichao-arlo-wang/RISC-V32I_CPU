#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;
unsigned int main_time = 0;

class RegFileTestBench : public BaseTestbench
{
protected:
    void initializeInputs() 
    {
        top->clk = 0;
        top->we3_i = 0;
        top->a1_i = 0;
        top->a2_i = 0;
        top->a3_i = 0;
        top->wd3_i = 0;
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

    void toggleClock() {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time ++;
    }   
};

uint32_t constant = 5;

TEST_F(RegFileTestBench, WriteAndReadBack)
{
    //Write data to register from 0 to 15
    for (int i = 0; i < 16; i++){
        top->we3_i = 1;
        top->a3_i = i;
        top->wd3_i = constant;
        toggleClock();
        toggleClock();

        top->we3_i = 0;

    }

    for (int i = 1; i < 16; i++){
        top->a1_i = i;
        top->eval();
        uint32_t out1 = top->rd1_o;
        EXPECT_EQ(out1, constant) << "Register" << i << " failed";
        toggleClock();
        toggleClock();
    }
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
