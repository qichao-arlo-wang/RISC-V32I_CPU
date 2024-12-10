module instr_mem_sys (
    input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,
    /* verilator lint_on UNUSED */

    output logic [31:0] instr_o
);

    logic l1_cache_hit;
    logic l2_cache_hit;
    logic l3_cache_hit;

    logic [31:0] l1_cache_data;
    logic [31:0] l2_cache_data;
    logic [31:0] l3_cache_data;
    logic [31:0] main_mem_data;

    logic l2_cache_valid;
    logic l3_cache_valid;

    l1_4way_instr_cache_4kb l1_instr_cache (
        .clk(clk),
        .addr_i(addr_i),

        .l2_cache_valid_i(l2_cache_valid),
        .l2_cache_data_i(l2_cache_data),

        .l1_cache_data_o(l1_cache_data),
        .l1_cache_hit_o(l1_cache_hit)
    );

    l2_4way_instr_cache_4kb l2_instr_cache (
        .clk(clk),
        .addr_i(addr_i),

        .l3_cache_valid_i(l3_cache_valid),
        .l3_cache_data_i(l3_cache_data),

        .l2_cache_data_o(l2_cache_data),
        .l2_cache_hit_o(l2_cache_hit),
        .l2_cache_valid_o(l2_cache_valid)
    );

    l3_8way_instr_cache_8kb l3_instr_cache (
        .clk(clk),
        .addr_i(addr_i),

        .main_mem_data_i(main_mem_data),

        .l3_cache_data_o(l3_cache_data),
        .l3_cache_hit_o(l3_cache_hit),
        .l3_cache_valid_o(l3_cache_valid)
    );

    // Instantiate the Instruction Memory
    instr_mem instr_mem_inst (
        .addr_i(addr_i),

        .instr_o(main_mem_data)
    );

    // Check L1, L2, L3 cache hit sequentially
    assign instr_o = l1_cache_hit ? l1_cache_data :
                    (l2_cache_hit && l2_cache_valid) ? l2_cache_data :
                    (l3_cache_hit && l3_cache_valid) ? l3_cache_data :
                    main_mem_data;
endmodule
