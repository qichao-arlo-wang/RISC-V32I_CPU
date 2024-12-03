#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../vbuddy.h"
#include <iostream>
#include <iomanip>

#define MAX_SIM_CYC 2000

int main(int argc, char **argv, char **env) {
    int simcyc; // simulation clock count
    int tick;   // each clk cycle has two ticks for two edges

    Verilated::commandArgs(argc, argv);

    // Instantiate top module and trace
    Vtop *top = new Vtop;
    VerilatedVcdC *tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("top.vcd");

    // Vbuddy initialization
    if (vbdOpen() != 1) return -1;
    vbdHeader("F1 Testbench");
    vbdSetMode(1);
    vbdBar(0);

    // Initialize inputs
    top->clk = 0;
    top->rst = 0;
    top->trigger = 0;

    // Simulation loop
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {
        for (tick = 0; tick < 2; tick++) {
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }

        // Reset and trigger logic
        //top->rst = (simcyc < 2) ? 1 : 0;
        //top->trigger = (simcyc > 2) ? vbdFlag() : 0;

        // Simulate changes to a0 for testing
        //if (simcyc % 20 == 0) {
        top->a0 = simcyc & 0xFF; // Debug: Simulate light updates
        //}

        // Vbuddy display
        vbdBar(top->a0 & 0xFF);
        vbdHex(3, (top->a0 >> 8) & 0xF);
        vbdHex(2, (top->a0 >> 4) & 0xF);
        vbdHex(1, top->a0 & 0xF);

        // End simulation if user quits
        if (Verilated::gotFinish() || vbdGetkey() == 'q') break;
    }

    // Close files and clean up
    vbdClose();
    tfp->close();
    delete top;
    return 0;
}
