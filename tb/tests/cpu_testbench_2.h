#pragma once

#include <utility>

#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "gtest/gtest.h"

#define MAX_SIM_CYCLES 10000

class CpuTestbench : public ::testing::Test
{
public:
    void SetUp() override
    {
        ticks_ = 0;
    }

    void setupTest(const std::string &name)
    {
        name_ = name;
        std::ignore = system(("/root/Documents/Group-9-RISC-V/tb/assemble.sh asm/" + name_ + ".s").c_str());
        std::ignore = system("touch data.hex");
    }

    void initSimulation()
    {
        top_ = new Vdut;  // No context for fallback
        tfp_ = new VerilatedVcdC;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        tfp_->open(("test_out/" + name_ + "/waveform.vcd").c_str());

        top_->clk = 1;
        top_->rst = 1;
        top_->trigger = 1;
        runSimulation(10);  // Process reset
        top_->rst = 0;
    }

    void runSimulation(int cycles = 1)
    {
        for (int i = 0; i < cycles; i++)
        {
            for (int clk = 0; clk < 2; clk++)
            {
                top_->eval();
                tfp_->dump(2 * ticks_ + clk);
                top_->clk = !top_->clk;
            }
            ticks_++;

            if (Verilated::gotFinish())
            {
                exit(0);
            }
        }
    }

    void TearDown() override
    {
        top_->final();
        tfp_->close();

        if (top_) delete top_;
        if (tfp_) delete tfp_;

        std::ignore = system(("mv data.hex test_out/" + name_ + "/data.hex").c_str());
        std::ignore = system(("mv program.hex test_out/" + name_ + "/program.hex").c_str());
    }

    void setData(const std::string &data_file)
    {
        std::ignore = system(("cp " + data_file + " data.hex").c_str());
    }

protected:
    Vdut* top_;
    VerilatedVcdC* tfp_;
    std::string name_;
    unsigned int ticks_;
};
