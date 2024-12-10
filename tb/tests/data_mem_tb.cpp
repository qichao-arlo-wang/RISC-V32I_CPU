#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;
unsigned int main_time = 0;

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

    void toggleClock() {
        top->clk = !top->clk;
        top->eval();
        tfp->dump(main_time);
        main_time ++;
    } 
};


// first full word data_mem read test case
TEST_F(DataMemTestbench, FullWordReadTest1)
{
    initializeInputs();
    top->byte_en_i = 0b1111;
    top->addr_i = 0x00010004;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0x77665544);
}

// second full word data_mem read test case
TEST_F(DataMemTestbench, FullWordReadTest2)
{
    initializeInputs();
    top->byte_en_i = 0b1111;
    top->addr_i = 0x00010008;
    top->eval();
    toggleClock();


    EXPECT_EQ(top->rd_data_o, 0xbbaa9988);
}

// third full word data_mem read test case
TEST_F(DataMemTestbench, FullWordReadTest3)
{
    initializeInputs();
    top->byte_en_i = 0b1111;
    top->addr_i = 0x0001000C;
    top->eval();
    toggleClock();


    EXPECT_EQ(top->rd_data_o, 0xffeeddcc);
}

// fourth full word data_mem read test case
TEST_F(DataMemTestbench, FullWordReadTest4)
{
    initializeInputs();
    top->byte_en_i = 0b1111;
    top->addr_i = 0x0001001C;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0xffeeddcc);
}

// half word data_mem read test case
TEST_F(DataMemTestbench, HalfWordReadTest)
{
    initializeInputs();
    top->byte_en_i = 0b0011;
    top->addr_i = 0x0001001C;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0xddcc);
}

// byte data_mem read test case
TEST_F(DataMemTestbench, ByteWordReadTest)
{
    initializeInputs();
    top->byte_en_i = 0b0001;
    top->addr_i = 0x0001001C;
    top->eval();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0xcc);
}

// full word write and read back test case
TEST_F(DataMemTestbench, FullWordDataMemWriteAndReadTest)
{
    initializeInputs();
    // Write data
    top->addr_i = 0x00010004;
    top->wr_en_i = 1;
    top->byte_en_i = 0b1111; // Enable all bytes
    top->wr_data_i = 0xAACCBBDD;
    top->eval();

    toggleClock();
    toggleClock();
    toggleClock();
    toggleClock();
    
    EXPECT_EQ(top->rd_data_o, 0xAACCBBDD);
}

// half word write and read back test case
TEST_F(DataMemTestbench, HalfWordDataMemPartialByteWriteTest)
{
    initializeInputs();

    // Write lower two bytes
    top->addr_i = 0x00010008;
    top->wr_en_i = 1;
    top->byte_en_i = 0b0011;    // Enable lower two bytes
    top->wr_data_i = 0x0000EEFF;
    top->eval();

    toggleClock();
    toggleClock();
    toggleClock();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0x0000EEFF); // Only lower bytes should be updated
}

// byte write and read back test case
TEST_F(DataMemTestbench, ByteDataMemPartialByteWriteTest)
{
    initializeInputs();

    top->addr_i = 0x00010008;
    top->wr_en_i = 1;
    top->byte_en_i = 0b0001;    // Enable lower two bytes
    top->wr_data_i = 0x000000FF;
    top->eval();

    toggleClock();
    toggleClock();
    toggleClock();
    toggleClock();

    EXPECT_EQ(top->rd_data_o, 0x000000FF); // Only lower bytes should be updated
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
