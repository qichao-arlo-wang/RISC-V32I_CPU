// This cpu_testbench_2.h file is enxing's version
// coz enxing's verilator version is not compatible with the original version
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
        // std::ignore = system(("./root/Documents/Group-9-RISC-V/tb/assemble.sh /root/Documents/Group-9-RISC-V/tb/asm/" + name_ + ".s").c_str());
        std::ignore = system("touch data.hex");
    }

    void initSimulation()
    {
        top_ = new Vdut;  // No context for fallback
        tfp_ = new VerilatedVcdC;

        Verilated::traceEverOn(true);
        top_->trace(tfp_, 99);
        tfp_->open(("/root/Documents/Group-9-RISC-V/tb/test_out/" + name_ + "/waveform.vcd").c_str());

        top_->clk = 1;
        top_->rst = 1;
        top_->trigger = 1; //changed this to trigger and start the program
        runSimulation(10);  // Process reset
        top_->rst = 0;
    }

    void runSimulation(int cycles)
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
        std::cout << "Closing simulation..." << std::endl;
        top_->final();
        tfp_->flush();        
        tfp_->close();
        std::cout << "Waveform saved." << std::endl;
        if (top_) delete top_;
        if (tfp_) delete tfp_;

        std::ignore = system(("mv data.hex /root/Documents/Group-9-RISC-V/tb/test_out/" + name_ + "/data.hex").c_str());
        std::ignore = system(("mv /root/Documents/Group-9-RISC-V/tb/program.hex /root/Documents/Group-9-RISC-V/tb/test_out/" + name_ + "/program.hex").c_str());
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
