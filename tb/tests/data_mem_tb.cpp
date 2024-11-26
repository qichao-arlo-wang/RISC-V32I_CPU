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

// first data_mem read test case
TEST_F(DataMemTestbench, DataMemWorksTest1)
{
    initializeInputs();
    top->addr_i = 0;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0x00112233);
}

// second data_mem read test case
TEST_F(DataMemTestbench, DataMemWorksTest2)
{
    initializeInputs();
    top->addr_i = 4;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0x44556677);
}

// third data_mem read test case
TEST_F(DataMemTestbench, DataMemWorksTest3)
{
    initializeInputs();
    top->addr_i = 8;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0x8899aabb);
}

// fourth data_mem read test case
TEST_F(DataMemTestbench, DataMemWorksTest4)
{
    initializeInputs();
    top->addr_i = 12;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0xccddeeff);
}

// fifth data_mem read test case
TEST_F(DataMemTestbench, DataMemWorksTest5)
{
    initializeInputs();
    top->addr_i = 32;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0xffeeddcc);
}

// unalighed address test case
TEST_F(DataMemTestbench, DataMemUnalignedAddressTest)
{
    initializeInputs();
    top->addr_i = 1; // Unaligned address
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0xDEADBEEF); // Should return error value
}

// out of range address test case
TEST_F(DataMemTestbench, DataMemOutOfRangeTest)
{
    initializeInputs();
    top->addr_i = 4096; // Address out of valid range
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0xDEADBEEF); // Should return error value
}

// write and read back test case
TEST_F(DataMemTestbench, DataMemWriteAndReadTest)
{
    initializeInputs();

    // Write data
    top->addr_i = 8;
    top->wr_en_i = 1;
    top->byte_en_i = 0b1111; // Enable all bytes
    top->wr_data_i = 0xAACCBBDD;
    top->eval();

    toggleClock(); // Simulate rising edge
    toggleClock(); // Simulate falling edge
    
    // Read back
    top->eval();
    EXPECT_EQ(top->rd_data_o, 0xAACCBBDD);
}

// Write with partial byte enable
TEST_F(DataMemTestbench, DataMemPartialByteWriteTest)
{
    initializeInputs();

    // Write lower two bytes
    top->addr_i = 8;
    top->wr_en_i = 1;
    top->byte_en_i = 0b0011; // Enable lower two bytes
    top->wr_data_i = 0x0000EEFF;
    top->eval();

    toggleClock(); // Simulate rising edge
    toggleClock(); // Simulate falling edge

    // Read back
    top->wr_en_i = 0;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0x0000EEFF); // Only lower bytes should be updated
}

// Write and check alignment warning
TEST_F(DataMemTestbench, DataMemWriteUnalignedTest)
{
    initializeInputs();

    // Write with unaligned address
    top->addr_i = 3; // Unaligned address
    top->wr_en_i = 1;
    top->byte_en_i = 0b1111;
    top->wr_data_i = 0x12345678;

    toggleClock(); // Simulate rising edge
    toggleClock(); // Simulate falling edge

    // Address error should prevent writing, and memory remains unchanged
    top->wr_en_i = 0;
    top->eval();

    EXPECT_EQ(top->rd_data_o, 0xDEADBEEF); // Unaligned write should not modify data
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
