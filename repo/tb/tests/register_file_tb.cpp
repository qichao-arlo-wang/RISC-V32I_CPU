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

    void toggleClock() {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time ++;
    }   
};

TEST_F(RegFileTestBench, WriteAndReadBack)
{
    //Write data to register from 1 to 32
    for (int i = 0; i < 16; i++){
        top->we = 1;
        top->wd = i;
        top->rd = i % (16);
        toggleClock();
        toggleClock();
        
        top->we = 0;
        toggleClock();
        toggleClock();
    }

    for (int i = 0; i < 16; i = i+2){
        top->rs1 = i;
        top->rs2 = i+1;
        uint32_t out1 = top->rd1;
        uint32_t out2 = top->rd2;

        EXPECT_EQ(out1, i % 16) << "Register " << i << "value mismatch!";
        EXPECT_EQ(out2, (i+1) % 16) << "Register" << i+1 << "value.mismatch!";
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
