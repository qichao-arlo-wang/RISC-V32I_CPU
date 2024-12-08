#include <cstdlib>
#include <utility>

#include "cpu_testbench.h"

// #include "cpu_testbench_2.h" 
// enxing's version

#define CYCLES 10000

TEST_F(CpuTestbench, TestAddiBne)
{
    setupTest("1_addi_bne");
    std::cout << "addi_bne" << std::endl;
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 254);
}

TEST_F(CpuTestbench, TestLiAdd)
{
    setupTest("2_li_add");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1000);
}

TEST_F(CpuTestbench, TestLbuSb)
{
    setupTest("3_lbu_sb");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 300);
}

TEST_F(CpuTestbench, TestJalRet)
{
    setupTest("4_jal_ret");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 53);
}

TEST_F(CpuTestbench, TestPdf)
{
    setupTest("5_pdf");
    system("pwd");
    setData("../reference/gaussian.mem");
    initSimulation();
    runSimulation(CYCLES * 100);
    EXPECT_EQ(top_->a0, 15363);
}

TEST_F(CpuTestbench, TestF1)
{
    setupTest("F1Assembly");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x254);
}

TEST_F(CpuTestbench, TestSLL)
{
    setupTest("6_sll");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x00000320);
}

TEST_F(CpuTestbench, TestSLT)
{
    setupTest("7_slt");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 4);
}

TEST_F(CpuTestbench, TestSLTU)
{
    setupTest("8_sltu");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 3);
}

TEST_F(CpuTestbench, TestSRLSRA)
{
    setupTest("9_srl_sra");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 1073741824);
}

TEST_F(CpuTestbench, TestAndXorOr)
{
    setupTest("10_and_xor_or");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x1A6);
}

TEST_F(CpuTestbench, TestLoadStore)
{
    setupTest("11_load_store");
    initSimulation();
    runSimulation(CYCLES);
    EXPECT_EQ(top_->a0, 0x9BE22467);
}

int main(int argc, char **argv)
{
    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();
    return res;
}
