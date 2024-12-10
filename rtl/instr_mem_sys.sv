module instr_mem_sys (
    input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,
    /* verilator lint_on UNUSED */

    output logic [31:0] instr_o
);

    logic [31:0] l1_cache_data;
    logic [31:0] main_mem_data;

    logic        l1_cache_hit;

    // Instantiate the Instruction Cache
    l1_4way_instr_cache_4kb l1_cache (
        .clk(clk),
        .addr_i(addr_i),
        .main_mem_data_i(main_mem_data),

        .l1_data_o(l1_cache_data),
        .l1_cache_hit_o(l1_cache_hit)
    );

    // Instantiate the Instruction Memory
    instr_mem instr_mem_inst (
        .addr_i(addr_i),

        .instr_o(main_mem_data)
    );

    // On a hit, use cached data; on a miss, use main_mem_instr directly
    assign instr_o = l1_cache_hit ? l1_cache_data : main_mem_data;

endmodule
