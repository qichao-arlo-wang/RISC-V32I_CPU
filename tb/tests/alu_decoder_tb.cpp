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

TEST_F(ALUDecoderTestBench, I_ADDI) {
    top->alu_op_i = 0; // 2'b00 for I-type arithmetic instructions
    top->funct3_i = 0; // funct3 = 000 for ADDI
    top->funct7_i = 0; // Not used for ADDI
    top->eval();
    EXPECT_EQ(top->alu_control_o, 0); // ADD operation
}

TEST_F(ALUDecoderTestBench, I_XORI) {
    top->alu_op_i = 0;
    top->funct3_i = 4; // funct3 = 100 for XORI
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 8); // XOR operation
}

TEST_F(ALUDecoderTestBench, I_ORI) {
    top->alu_op_i = 0;
    top->funct3_i = 6; // funct3 = 110 for ORI
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 7); // OR operation
}

TEST_F(ALUDecoderTestBench, I_ANDI) {
    top->alu_op_i = 0;
    top->funct3_i = 7; // funct3 = 111 for ANDI
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 9); // AND operation
}

TEST_F(ALUDecoderTestBench, I_SLLI) {
    top->alu_op_i = 0;
    top->funct3_i = 1; // funct3 = 001 for SLLI
    top->funct7_i = 0; // funct7 = 0b0000000 for SLLI
    top->eval();
    EXPECT_EQ(top->alu_control_o, 2); // SLL operation
}

TEST_F(ALUDecoderTestBench, I_SRLI) {
    top->alu_op_i = 0;
    top->funct3_i = 5; // funct3 = 101 for SRLI
    top->funct7_i = 0; // funct7 = 0b0000000 for SRLI
    top->eval();
    EXPECT_EQ(top->alu_control_o, 5); // SRL operation
}

TEST_F(ALUDecoderTestBench, I_SRAI) {
    top->alu_op_i = 0;
    top->funct3_i = 5;  // funct3 = 101 for SRAI
    top->funct7_i = 32; // funct7 = 0b0100000 (decimal 32) for SRAI
    top->eval();
    EXPECT_EQ(top->alu_control_o, 6); // SRA operation
}

TEST_F(ALUDecoderTestBench, I_SLTI) {
    top->alu_op_i = 0;
    top->funct3_i = 2; // funct3 = 010 for SLTI
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 3); // SLT operation
}

TEST_F(ALUDecoderTestBench, I_SLTIU) {
    top->alu_op_i = 0;
    top->funct3_i = 3; // funct3 = 011 for SLTIU
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 4); // SLTU operation
}

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

TEST_F(ALUDecoderTestBench, R_SLL) {
    top->alu_op_i = 2;
    top->funct3_i = 1;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 2); // SLL operation
}

TEST_F(ALUDecoderTestBench, R_SLT) { 
    top->alu_op_i = 0;
    top->funct3_i = 2;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 3); // SLT operation
}

TEST_F(ALUDecoderTestBench, R_SLTU) { 
    top->alu_op_i = 0;
    top->funct3_i = 3;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 4); // SLTU operation
}

TEST_F(ALUDecoderTestBench, R_SRL) {
    top->alu_op_i = 2;
    top->funct3_i = 5;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 5); // SRL operation
}

TEST_F(ALUDecoderTestBench, R_SRA) {  
    top->alu_op_i = 0;
    top->funct3_i = 5;  //funct3 = 101
    top->funct7_i = 32; //funct7 = 0b0100000
    top->eval();
    EXPECT_EQ(top->alu_control_o, 6); //SRA operation
}

TEST_F(ALUDecoderTestBench, R_OR) {
    top->alu_op_i = 2;
    top->funct3_i = 6;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 7); // OR operation
}

TEST_F(ALUDecoderTestBench, R_XOR) {
    top->alu_op_i = 2;
    top->funct3_i = 4;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 8); // XOR operation
}

TEST_F(ALUDecoderTestBench, R_AND) {
    top->alu_op_i = 2;
    top->funct3_i = 7;
    top->funct7_i = 0;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 9); // AND operation
}

TEST_F(ALUDecoderTestBench, B_BRANCH) {
    top->alu_op_i = 1; // 2'b01 for B-type instructions
    top->funct3_i = 0; // funct3 varies, but alu_control_o should be SUB
    top->funct7_i = 0; // Not used for branches
    top->eval();
    EXPECT_EQ(top->alu_control_o, 1); // SUB operation for branch comparisons
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
