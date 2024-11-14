#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vregister_file.h"
#include "gtest/gtest.h"

extern Vregister_file *top;
extern VerilatedVcdC *tfp;
extern unsigned int ticks = 0;

class RegfileTestbench : public ::testing::Test
{
protected:
    vluint64_t main_time;

    void SetUp() override
    {   
        top = new Vregister_file;
        initializeInputs();
        main_time = 0;
    }

    void TearDown() override
    {
        removeTestEnv();
    }

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
    
    void removeTestEnv() override {
        delete reg
    }

    void toggleClock() {
        top->clk = !top->clk;
        top->eval();
        main_time ++;
    }   
};

TEST_F(RegfileTestbench, WriteAndReadBack)
{
    //Write data to register from 1 to 32
    for (int i = 0; i < 0xFFFFFFFF; i++){
        top->we = 1;
        top->wd = i;
        top->rd = i % (16);
        toggleClock();
        toggleClock();
        
        top->we = 0;
        toggleClock();
        toggleClock();
    }

    for (int i = 0; i < 0xFFFFFFFF; i = i+2){
        top->rs1 = i;
        top->rs2 = i+1;
        out1 = top->rd1;
        out2 = top->rd2;

        EXPECT_EQ(out1, i % 16) << "Register " << i << "value mismatch!";
        EXPECT_EQ(out2, (i+1) % 16) << "Register" << i+1 << "value.mismatch!";
        toggleClock();
        toggleClock();
    }
}
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
