#include "base_testbench.h"

Vdut *top;

class ALUDecoderTestBench : public BaseTestbench
{
protected:
    void initializeInputs() 
    {
        top->alu_op_i = 3;
        top->funct3_i = 7;
        top->funct7_i = 1;
    }
};

TEST_F(ALUDecoderTestBench, LW_SW)
{
    top->alu_op_i = 0;
    top->funct3_i = 4;
    top->funct7_i = 1;
    top->eval();
    EXPECT_EQ(top->alu_control_o, 0);
}

TEST_F(ALUDecoderTestBench, R_ADD){
    top->alu_op_i = 2;
    top->funct3_i = 0;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 0);
}

TEST_F(ALUDecoderTestBench, R_SUB){
    top->alu_op_i = 2;
    top->funct3_i = 0;
    top->funct7_i = 1;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 1);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_LEFT_LOGICAL){
    top->alu_op_i = 2;
    top->funct3_i = 1;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 5);
}

// TEST_F(ALUDecoderTestBench, R_SET_LESS_THAN){ //dont know how to implement this
//     top->alu_op_i = 2;
//     top->funct3_i = 2;
//     top->funct7_i = 0;

//     EXPECT_EQ(top->alu_control_o, 3'b)
// }

TEST_F(ALUDecoderTestBench, R_XOR){
    top->alu_op_i = 2;
    top->funct3_i = 4;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 4);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_RIGHT_LOGICAL){
    top->alu_op_i = 2;
    top->funct3_i = 5;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 6);
}

TEST_F(ALUDecoderTestBench, R_OR){
    top->alu_op_i = 2;
    top->funct3_i = 6;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 3);
}

TEST_F(ALUDecoderTestBench, R_AND){
    top->alu_op_i = 2;
    top->funct3_i = 7;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 2);
}

TEST_F(ALUDecoderTestBench, DEFAULT_CASE) {
    top->alu_op_i = 3;  // Invalid ALU operation
    top->funct3_i = 0;
    top->funct7_i = 0;
    top->eval();

    EXPECT_EQ(top->alu_control_o, 0);  // Default case
}

int main(int argc, char **argv)
{
    top = new Vdut;

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();

    delete top;

    return res;
}