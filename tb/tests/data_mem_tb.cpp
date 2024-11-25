#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class DataMemTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->addr_i = 0;
        top->wr_en_i = 0;
        top->wr_data_i = 0;
        top->byte_en_i = 0;
    }
};

// first normal test case
TEST_F(DataMemTestbench, DataMemWorksTest1)
{

}

// second normal test case
TEST_F(DataMemTestbench, DataMemWorksTest2)
{

}

// third normal test case
TEST_F(DataMemTestbench, DataMemWorksTest3)
{

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
