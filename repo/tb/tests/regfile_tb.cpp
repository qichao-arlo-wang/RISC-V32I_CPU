#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vregister_file.h"
#include "gtest/gtest.h"

// register file has 4 bits address and each input is 32 bits wide

class RegfileTestbench : public ::testing::Test
{
protected:
    Vregister_fule *reg_file;
    VerilatedVcdC *tfp;
    vluint64_t main_time;
    unsigned int ticks;

    void SetUp() override
    {   
        Verilated::traceEverOn(true);
        reg_file = new Vregister_file;
        tfo - new VerilatedVcdC;
        reg_file->trace(tfp, 99)
        tfp->open("regfile_waveform.vcd")
        initializeInputs();
        main_time = 0;
        ticks = 0;
    }

    void TearDown() override
    {
        reg_file->final();
        tfp->close();
        delete reg_file;
        delete tfp;
    }

    void initializeInputs() 
    {
        reg_file->clk = 0;
        reg_file->we = 0;
        reg_file->rs1 = 0;
        reg_file->rs2 = 0;
        reg_file->rd = 0;
        reg_file->wd = 0;
    }


    void runSimulation()
    {
        for (int clk = 0; clk < 2; clk++)
        {
            reg_file->eval();
            tfp->dump(2 * ticks + clk);
            reg_file->clk = !reg_file->clk;
        }
        ticks ++;

        if (Verilated::gotFinish())
        {
            exit(0);
        }
    }

    void toggleClock() {
        reg_file->clk = !reg_file->clk;
        reg_file->eval();
        tfp->dump(main_time);
        main_time ++;
    }   
};

TEST_F(RegfileTestbench, WriteAndReadBack)
{
    //Write data to register from 1 to 32
    for (int i = 0; i < 16; i++){
        reg_file->we = 1;
        reg_file->wd = i;
        reg_file->rd = i % (16);
        toggleClock();
        toggleClock();
        
        reg_file->we = 0;
        toggleClock();
        toggleClock();
    }

    for (int i = 0; i < 16; i = i+2){
        reg_file->rs1 = i;
        reg_file->rs2 = i+1;
        unit32_t out1 = reg_file->rd1;
        uint32_t out2 = reg_file->rd2;

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
