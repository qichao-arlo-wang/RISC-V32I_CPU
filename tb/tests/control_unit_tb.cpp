#include "base_testbench.h"
#include "Vdut.h"
#include "gtest/gtest.h"
#include "verilated.h"

Vdut *top;

class ControlUnitTestBench : public testing::Test {
protected:
    void SetUp() override {
        top = new Vdut;  // Initialize the top module
        initializeInputs();
    }

    void TearDown() override {
        top->final();
        delete top;
        top = nullptr;
    }

    void initializeInputs() {
        top->opcode_i = 0;
        top->funct3_i = 0;
        top->funct7_i = 0;
        top->zero_i = 0;
        top->alu_result_i = 0;    
    }
};


//Test for ADDI instruction I-type
TEST_F(ControlUnitTestBench, ADDI){
    top->opcode_i = 0b0010011; //ADDI opcode
    top->funct3_i = 0b000; //ADDI funct3
    top->funct7_i = 0; //not used for ADDI
    top->zero_i = 0; //zero flag not used for ADDI

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1); //reg write enabled
    EXPECT_EQ(top->alu_src_o, 1); //alu uses immediate
    EXPECT_EQ(top->alu_control_o, 0x0); //alu control for add
    EXPECT_EQ(top->pc_src_o, 0); //no branch
}

// Test for BEQ instruction
TEST_F(ControlUnitTestBench, BEQ_TEST) {
    top->opcode_i = 0b1100011; // Branch opcode
    top->funct3_i = 0b000;     // BEQ
    top->funct7_i = 0;       // Not significant for BEQ
    top->zero_i = 1;           // Zero flag set (branch condition met)

    top->eval();

    EXPECT_EQ(top->pc_src_o, 1);       // Branch taken
}

// Test for BNE instruction B-type
TEST_F(ControlUnitTestBench, BNE_TEST){
    top->opcode_i = 0b1100011; //branch opcode
    top->funct3_i = 0b001; //BNE funct3
    top->funct7_i = 0; //not significant for BNE
    top->zero_i = 0; // zero flag not set

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0); //no reg write
    EXPECT_EQ(top->alu_src_o, 0); //alu uses reg inputs
    EXPECT_EQ(top->pc_src_o, 1); //branch taken
    EXPECT_EQ(top->alu_control_o, 0x1); //alu control code for sub
}

// Test for BLT instruction
TEST_F (ControlUnitTestBench, BLT_TEST){
    top->opcode_i = 0b1100011; //branch opcode
    top->funct3_i = 0b001; //BLT funct3
    top->funct7_i = 0; //not significant for BLT
    top->zero_i = 0; // zero flag not set
    top->alu_result_i = -1;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0); //no reg write
    EXPECT_EQ(top->alu_src_o, 0); //alu uses reg inputs
    EXPECT_EQ(top->pc_src_o, 1); //branch taken
    EXPECT_EQ(top->alu_control_o, 0x1);
}

// Test for BLTU instruction
TEST_F (ControlUnitTestBench, BLTU_TEST){
    top->opcode_i = 0b1100011; //branch opcode
    top->funct3_i = 0b111; //BLTU funct3
    top->funct7_i = 0; //not significant for BLTU
    top->zero_i = 1; // zero-extends
    top->alu_result_i = -1;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0); //no reg write
    EXPECT_EQ(top->alu_src_o, 0); //alu uses reg inputs
    EXPECT_EQ(top->pc_src_o, 1); //branch taken
    EXPECT_EQ(top->alu_control_o, 0x1);
}

// Test for BGE instruction
TEST_F (ControlUnitTestBench, BGE_TEST){
    top->opcode_i = 0b1100011; //branch opcode
    top->funct3_i = 0b101; //BGE funct3
    top->funct7_i = 0; //not significant for BGE
    top->zero_i = 0; // zero flag not set
    top->alu_result_i = 1;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0); //no reg write
    EXPECT_EQ(top->alu_src_o, 0); //alu uses reg inputs
    EXPECT_EQ(top->pc_src_o, 1); //branch taken
    EXPECT_EQ(top->alu_control_o, 0x1);
}

// Test for BGEU instruction
TEST_F (ControlUnitTestBench, BGEU_TEST){
    top->opcode_i = 0b1100011; //branch opcode
    top->funct3_i = 0b111; //BGEU funct3
    top->funct7_i = 0; //not significant for BGE
    top->zero_i = 1; // zero extends
    top->alu_result_i = -1;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0); //no reg write
    EXPECT_EQ(top->alu_src_o, 0); //alu uses reg inputs
    EXPECT_EQ(top->pc_src_o, 1); //branch taken
    EXPECT_EQ(top->alu_control_o, 0x1);
}

// Test for R-type instruction
TEST_F(ControlUnitTestBench, R_TYPE) {
    top->opcode_i = 0b0110011; // R-Type opcode
    top->funct3_i = 0b000;     // ADD operation
    top->funct7_i = 0;       // No significance for ADD
    top->zero_i = 0;           // Zero flag not used for R-type

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1);     // Register write enabled
    EXPECT_EQ(top->alu_src_o, 0);       // ALU uses register inputs
    EXPECT_EQ(top->alu_control_o, 0x0); // ALU control for ADD (4-bit value)
    EXPECT_EQ(top->pc_src_o, 0);        // No branch
}

// Test for Store instruction
TEST_F(ControlUnitTestBench, STORE_SW) {
    top->opcode_i = 0b0100011; // Store opcode
    top->funct3_i = 0b010;     // SW
    top->funct7_i = 0;       // Not significant for SW
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0);     // No register write
    EXPECT_EQ(top->mem_wr_en_o, 1);     // Memory write enabled
}

// Test for JAL instruction
TEST_F(ControlUnitTestBench, JAL) {
    top->opcode_i = 0b1101111; // Store opcode
    top->funct3_i = 0b000;     
    top->funct7_i = 0;       
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1);     // No register write
    EXPECT_EQ(top->mem_wr_en_o, 0);     // Memory write enabled
    EXPECT_EQ(top->pc_src_o, 1);        //PC source for JAL
}

TEST_F(ControlUnitTestBench, JALR) {
    top->opcode_i = 0b1100111; // Store opcode
    top->funct3_i = 0b000;   
    top->funct7_i = 0;     
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1);     // No register write
    EXPECT_EQ(top->mem_wr_en_o, 0);     // Memory write enabled
    EXPECT_EQ(top->pc_src_o, 1);        ///pc source for jalr
}

TEST_F(ControlUnitTestBench, LUI) {
    top->opcode_i = 0b0110111; // Store opcode
    top->funct3_i = 0;   
    top->funct7_i = 0;     
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1);     // No register write
    EXPECT_EQ(top->mem_wr_en_o, 0);     // Memory write enabled
    EXPECT_EQ(top->result_src_o, 0);    //result source for LUI
    EXPECT_EQ(top->pc_src_o, 0);
}
  
TEST_F(ControlUnitTestBench, AUIPC) {
    top->opcode_i = 0b0010111; // Store opcode
    top->funct3_i = 0;   
    top->funct7_i = 0;     
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 1);     // No register write
    EXPECT_EQ(top->mem_wr_en_o, 0);     // Memory write enabled
    EXPECT_EQ(top->result_src_o, 0);    //result source for AUIPC
    EXPECT_EQ(top->pc_src_o, 0);        //no branch
}

// Test for default case
TEST_F(ControlUnitTestBench, DEFAULT_CASE) {
    top->opcode_i = 0b1111111; // Invalid opcode
    top->funct3_i = 0;
    top->funct7_i = 0;
    top->zero_i = 0;

    top->eval();

    EXPECT_EQ(top->reg_wr_en_o, 0);   // No register write
    EXPECT_EQ(top->alu_control_o, 0x0); // Default ALU operation
    EXPECT_EQ(top->pc_src_o, 0);      // No branch
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);  // Initialize Verilator args
    testing::InitGoogleTest(&argc, argv);
    
    top = new Vdut;
    
    auto res = RUN_ALL_TESTS();
    
    top->final();
    delete top;

    return res;
}
