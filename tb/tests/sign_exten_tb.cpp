#include "base_testbench.h"

Vdut *top;

class SignExtenTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->instr_31_7_i = 0;
        top->imm_src_i = 0;
    }
};

TEST_F(SignExtenTestbench, I_TYPE_POS)
{
    top->instr_31_7_i = 0b0010101101110100000110000;
    top->imm_src_i = 0;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, 695);
}

TEST_F(SignExtenTestbench, I_TYPE_NEG)
{
    top->instr_31_7_i = 0b1110101101110100000110000;
    top->imm_src_i = 0;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, -1315);
}

TEST_F(SignExtenTestbench, S_TYPE)
{
    top->instr_31_7_i = 0b0100011011110011011001110;
    top->imm_src_i = 1;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, 1134);
}

TEST_F(SignExtenTestbench, S_TYPE_NEG)
{
    top->instr_31_7_i = 0b1101001010101000000101010;
    top->imm_src_i = 1;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, -726);
}

TEST_F(SignExtenTestbench, U_TYPE){
    top->instr_31_7_i = 0b1101001010101000000101010;
    top->imm_src_i = 3;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, 27611168);
}

TEST_F(SignExtenTestbench, B_TYPE){
    top->instr_31_7_i = 0b0101001010101000000101010;
    top->imm_src_i = 2;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, 645);
}

TEST_F(SignExtenTestbench, B_TYPE_NEG){
    top->instr_31_7_i = 0b1111100000100000011000001;
    top->imm_src_i = 2;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, -4);
}   

TEST_F(SignExtenTestbench, J_TYPE){
    top->instr_31_7_i = 0b0101101011010100010000001;
    top->imm_src_i = 4;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, 177236);
}

TEST_F(SignExtenTestbench, J_TYPE_NEG){
    top->instr_31_7_i = 0b1111010110011111111100001;
    top->imm_src_i = 4;
    top->eval();

    EXPECT_EQ(top->imm_ext_o, -340);

}

TEST_F(SignExtenTestbench, DEFAULT){
    top->instr_31_7_i = 0b1111010110011111111100001;
    top->imm_src_i = 5;
    top->eval();

    EXPECT_EQ(top->imm_ext_o , 0);
}
int main(int argc, char **argv)
{
    top = new Vdut;

    // Verilated::traceEverOn(true);
    // top->trace(tfp, 99);
    // tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();

    delete top;

    return res;
}