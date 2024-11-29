#include "base_testbench.h"
#include "Vdut.h"
#include "gtest/gtest.h"

Vdut *top;

class ALUDecoderTestBench : public BaseTestbench {
protected:
    void initializeInputs() {
        top->alu_op_i = 0;
        top->funct3_i = 0;
        top->funct7_i = 0;
    }
};

TEST_F(ALUDecoderTestBench, LW_SW) {
    top->alu_op_i = 3; // 2'b11 for load/store instructions
    top->funct3_i = 2; // LW/SW
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 0); // ADD operation
}

TEST_F(ALUDecoderTestBench, R_ADD) {
    top->alu_op_i = 2;
    top->funct3_i = 0;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 0); // ADD operation
}

TEST_F(ALUDecoderTestBench, R_SUB) {
    top->alu_op_i = 2;
    top->funct3_i = 0;
    top->funct7_i = 32; // 7'h20
    top->eval();
    EXPECT_EQ(top->alu_control_o, 1); // SUB operation
}

TEST_F(ALUDecoderTestBench, R_SHIFT_LEFT_LOGICAL) {
    top->alu_op_i = 2;
    top->funct3_i = 1;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 2); // SLL operation
}

TEST_F(ALUDecoderTestBench, R_XOR) {
    top->alu_op_i = 2;
    top->funct3_i = 4;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 8); // XOR operation
}

TEST_F(ALUDecoderTestBench, R_SHIFT_RIGHT_LOGICAL) {
    top->alu_op_i = 2;
    top->funct3_i = 5;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 5); // SRL operation
}

TEST_F(ALUDecoderTestBench, R_OR) {
    top->alu_op_i = 2;
    top->funct3_i = 6;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 7); // OR operation
}

TEST_F(ALUDecoderTestBench, R_AND) {
    top->alu_op_i = 2;
    top->funct3_i = 7;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 9); // AND operation
}

TEST_F(ALUDecoderTestBench, DEFAULT_CASE) {
    top->alu_op_i = 3;  // Invalid ALU operation
    top->funct3_i = 0;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 0);  // Default to ADD operation
}

int main(int argc, char **argv) {
    top = new Vdut;

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();

    delete top;

    return res;
}
