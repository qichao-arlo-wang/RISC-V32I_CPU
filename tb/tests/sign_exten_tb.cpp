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

    top->imm_ext_o = 2781;
}

TEST_F(SignExtenTestbench, I_TYPE_NEG)
{
    top->instr_31_7_i = 0b1110101101110100000110000;
    top->imm_src_i = 0;
    top->eval();

   top->imm_ext_o = -1315; //4294967150
}

TEST_F(SignExtenTestbench, S_TYPE)
{
    top->instr_31_7_i = 0b0100011011110011011001110;
    top->imm_src_i = 1;
    top->eval();

   top->imm_ext_o = -146;
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