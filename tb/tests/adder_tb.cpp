#include "base_testbench.h"
#include <climits>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class AdderTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->in1_i = 0;
        top->in2_i = 0;
    }
};

// adder simple works test
TEST_F(AdderTestbench, AdderWorksTest)
{
    top->in1_i = 5;
    top->in2_i = 10;

    top->eval();

    EXPECT_EQ(top->out_o, 15);
}

// adder zero test
TEST_F(AdderTestbench, AdderZeroTest)
{
    top->in1_i = 0;
    top->in2_i = 0;

    top->eval();

    EXPECT_EQ(top->out_o, 0);
}

// adder negative test
TEST_F(AdderTestbench, AdderNegativeTest)
{
    top->in1_i = -5;
    top->in2_i = -10;

    top->eval();

    EXPECT_EQ(top->out_o, -15);
}

// adder max int test
TEST_F(AdderTestbench, AdderMaxIntTest)
{
    top->in1_i = INT_MAX;
    top->in2_i = 1;

    top->eval();
    // Use int64_t to safely handle the addition without overflow
    int64_t expected = static_cast<int64_t>(INT_MAX) + 1;
    EXPECT_EQ(static_cast<int64_t>(top->out_o), expected);
    
    // EXPECT_EQ(top->out, INT_MAX + 1);  this works too but the above is more safe without overflow
}


// adder min int test
TEST_F(AdderTestbench, AdderMinIntTest)
{
    top->in1_i = INT_MIN;
    top->in2_i = -1;

    top->eval();

    // Use int64_t to safely handle the subtraction without overflow
    int64_t expected = static_cast<int64_t>(INT_MIN) - 1;
    expected = static_cast<int32_t>(expected); // Simulate 32-bit wraparound
    EXPECT_EQ(static_cast<int32_t>(top->out_o), expected);
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