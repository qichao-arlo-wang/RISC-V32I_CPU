#include "base_testbench.h"

Vdut *top;

class ALUDecoderTestBench : public BaseTestbench
{
protected:
    void initializeInputs() 
    {
        top->alu_op = 2'b11;
        top->funct3 = 3'b111;
        top->funct7_5 = 1;
    }
};

TEST_F(ALUDecoderTestBench, LW_SW) //need to change
{
    top->alu_op = 2'b00;
    top->funct3 = 3'd4;
    top->funct7_5 = 1;

    EXPECT_EQ(top->alu_control, 3'b000);
}

TEST_F(ALUDecoderTestBench, R_ADD){
    top->alu_op = 2'b10;
    top->funct3 = 3'000;
    top->funct7_5 = 1'b0;

    EXPECT_EQ(top->alu_control, 3'b000);
}

TEST_F(ALUDecoderTestBench, R_SUB){
    top->alu_op = 2'b10;
    top->funct3 = 3'b000;
    top->funct7_5 = 1'b1;

    EXPECT_EQ(top->alu_control, 3'b001);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_LEFT_LOGICAL){
    top->alu_op = 2'b10;
    top->funct3 = 3'b001;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b101);
}

TEST_F(ALUDecoderTestBench, R_SET_LESS_THAN){ //dont know how to implement this
    top->alu_op = 2'b10;
    top->funct3 = 3'b010;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b)
}

TEST_F(ALUDecoderTestBench, R_XOR){
    top->alu_op = 2'b10;
    top->funct3 = 3'b100;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b100);
}

TEST_F(ALUDecoderTestBench, R_SHIFT_RIGHT_LOGICAL){
    top->alu_op = 2'b10;
    top->funct3 = 3'b101;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b1110);
}

TEST_F(ALUDecoderTestBench, R_OR){
    top->alu_op = 2'b10;
    top->funct3 = 3'b110;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b011);
}

TEST_F(ALUDecoderTestBench, R_ADD){
    top->alu_op = 2'b10;
    top->funct3 = 3'b111;
    top->funct7_5 = 0;

    EXPECT_EQ(top->alu_control, 3'b010);
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