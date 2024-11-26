#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;
unsigned int main_time = 0;

class PcRegTestBench : public BaseTestbench
{
protected:
    void initializeInputs() 
    {
        top->clk = 0;
        top->pc_next_i = 0;
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

TEST_F(PcRegTestBench, BaseTest1)
{   
    //Write data to register
    top->pc_next_i = 10;
    toggleClock();
    toggleClock();
    toggleClock();
    // toggleClock();
    top->eval();

    EXPECT_EQ(top->pc_o, 10);
}

// initialization test
TEST_F(PcRegTestBench, InitializationTest)
{
    initializeInputs();
    toggleClock();
    top->eval();

    EXPECT_EQ(top->pc_o, 0);
}

// continuous update test
TEST_F(PcRegTestBench, ContinuousUpdateTest)
{
    top->pc_next_i = 10;
    toggleClock();
    toggleClock();
    toggleClock();
    top->eval();
    EXPECT_EQ(top->pc_o, 10);

    top->pc_next_i = 20;
    toggleClock();
    toggleClock();
    toggleClock();
    top->eval();
    EXPECT_EQ(top->pc_o, 20);

    top->pc_next_i = 30;
    toggleClock();
    toggleClock();
    toggleClock();
    top->eval();
    EXPECT_EQ(top->pc_o, 30);
}

// max value test
TEST_F(PcRegTestBench, MaxValueTest)
{
    top->pc_next_i = 0xFFFFFFFF;
    toggleClock();
    toggleClock();
    toggleClock();
    top->eval();
    EXPECT_EQ(top->pc_o, 0xFFFFFFFF);

    top->pc_next_i = 0;
    toggleClock();
    toggleClock();
    toggleClock();
    top->eval();
    EXPECT_EQ(top->pc_o, 0);
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
