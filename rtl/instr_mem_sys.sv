module instr_mem_sys (
    input  logic        clk,
    input  logic [31:0] addr_i,
    output logic [31:0] instr_o,
    output logic        cache_hit_o
);

    logic [31:0] instr_cache_data;
    logic [31:0] main_mem_instr;

    // Instantiate the Instruction Cache
    l1_4way_instr_cache_4kb l1_icache (
        .clk(clk),
        .addr_i(addr_i),
        .main_mem_instr(main_mem_instr),
        .instr_o(instr_cache_data),
        .cache_hit_o(cache_hit_o)
    );

    // Instantiate the Instruction Memory
    instr_mem instr_mem_inst (
        .addr_i(addr_i),
        .instr_o(main_mem_instr)
    );

    // On a hit, use cached data; on a miss, use main_mem_instr directly
    assign instr_o = cache_hit_o ? instr_cache_data : main_mem_instr;

endmodule
