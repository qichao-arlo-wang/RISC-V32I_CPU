#include "Vcontrol_unit.h"  // Ensure this matches the Verilator-generated file
#include "gtest/gtest.h"
#include "verilated.h"

// Test Fixture
class ControlUnitTestBench : public ::testing::Test {
protected:
    Vcontrol_unit *top;  // Pointer to the Verilated DUT model

    void SetUp() override {
        top = new Vcontrol_unit;
        top->clk = 0; // Initialize the clock
    }

    void TearDown() override {
        delete top;
    }
};


// Test for R-type instruction
TEST_F(ControlUnitTestBench, R_TYPE) {
    top->opcode = 0b0110011; // R-Type opcode
    top->funct3 = 0b000;     // ADD operation
    top->funct7_5 = 0;       // No significance for ADD
    top->zero = 0;           // Zero flag not used for R-type
    top->eval();

    EXPECT_EQ(top->reg_wr_en, 1); // Register write enabled
    EXPECT_EQ(top->alu_src, 0);   // ALU uses register inputs
    EXPECT_EQ(top->alu_control, 0); // ALU control for ADD
    EXPECT_EQ(top->pc_src, 0);    // No branch
}

// Test for Store instruction
TEST_F(ControlUnitTestBench, STORE_SW) {
    top->opcode = 0b0100011; // Store opcode
    top->funct3 = 0b010;     // SW
    top->funct7_5 = 0;       // Not significant for SW
    top->zero = 0;
    top->eval();

    EXPECT_EQ(top->reg_wr_en, 0);     // No register write
    EXPECT_EQ(top->mem_wr_en, 1);     // Memory write enabled
}

// Test for Branch instruction
TEST_F(ControlUnitTestBench, BRANCH_BEQ) {
    top->opcode = 0b1100011; // Branch opcode
    top->funct3 = 0b000;     // BEQ
    top->funct7_5 = 0;       // Not significant for BEQ
    top->zero = 1;           // Zero flag set (branch condition met)
    top->eval();

    EXPECT_EQ(top->pc_src, 1);       // Branch taken
}

// Test for default case
TEST_F(ControlUnitTestBench, DEFAULT_CASE) {
    top->opcode = 0b1111111; // Invalid opcode
    top->funct3 = 0;
    top->funct7_5 = 0;
    top->zero = 0;
    top->eval();

    EXPECT_EQ(top->reg_wr_en, 0);   // No register write
    EXPECT_EQ(top->alu_control, 0); // Default ALU operation
    EXPECT_EQ(top->pc_src, 0);      // No branch
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
