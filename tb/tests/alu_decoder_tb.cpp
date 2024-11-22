#include "base_testbench.h"

Vdut *top;

class ALUDecoderTestBench : public BaseTestbench
{
protected:
    void initializeInputs() 
    {
        top->alu_op = 3;
        top->funct3 = 7;
        top->funct7_5 = 1;
    }
};

TEST_F(ALUDecoderTestBench, LW_SW) //need to change
{
    top->alu_op = 0;
    top->funct3 = 4;
    top->funct7_5 = 1;

    EXPECT_EQ(top->alu_control, 0);
}

TEST_F(ALUDecoderTestBench, R_ADD){
    top->alu_op = 2;
    top->funct3 = 0;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 0);
}

TEST_F(ALUDecoderTestBench, R_SUB){
    top->alu_op = 2;
    top->funct3 = 0;
    top->funct7_5 = 1;

    EXPECT_EQ(top->alu_control, 1);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_LEFT_LOGICAL){
    top->alu_op = 2;
    top->funct3 = 1;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 5);
}

TEST_F(ALUDecoderTestBench, R_SET_LESS_THAN){ //dont know how to implement this
    top->alu_op = 2;
    top->funct3 = 2;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b)
}

TEST_F(ALUDecoderTestBench, R_XOR){
    top->alu_op = 2;
    top->funct3 = 4;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 4);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_RIGHT_LOGICAL){
    top->alu_op = 2;
    top->funct3 = 5;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 6);
}

TEST_F(ALUDecoderTestBench, R_OR){
    top->alu_op = 2;
    top->funct3 = 6;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3);
}

TEST_F(ALUDecoderTestBench, R_ADD){
    top->alu_op = 2;
    top->funct3 = 7;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 2);
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