// Top-Level Module Integrating Cache and Memory
module data_mem_sys (
    input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,    // mem address
    /* verilator lint_on UNUSED */
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
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
    logic main_mem_valid;

    // Instantiate the L1 Cache
    l1_4way_data_cache_4kb l1_cache (
        .clk(clk),
        .wr_en_i(wr_en_i),
        .addr_i(addr_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),

        .l2_cache_valid_i(l2_cache_valid),
        .l2_cache_data_i(l2_cache_data),

        .l1_cache_hit_o(l1_cache_hit),
        .l1_rd_data_o(l1_cache_data)
    );

    // Instantiate the L2 Cache
    l2_4way_data_cache_4kb l2_cache (
        .clk(clk),
        .wr_en_i(wr_en_i),
        .addr_i(addr_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),

        .l3_cache_valid_i(l3_cache_valid),
        .l3_cache_data_i(l3_cache_data),

        .l2_cache_valid_o(l2_cache_valid),
        .l2_cache_hit_o(l2_cache_hit),
        .l2_rd_data_o(l2_cache_data)
    );

    // Instantiate the L3 Cache
    l3_8way_data_cache_8kb l3_cache (
        .clk(clk),
        .wr_en_i(wr_en_i),
        .addr_i(addr_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),

        .main_mem_valid_i(main_mem_valid),
        .main_mem_data_i(main_mem_data),

        .l3_cache_valid_o(l3_cache_valid),
        .l3_cache_hit_o(l3_cache_hit),
        .l3_rd_data_o(l3_cache_data)
    );

    // Instantiate the Data Memory
    data_mem data_memory_inst (
        .clk(clk),
        .addr_i(addr_i),
        .wr_en_i(wr_en_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),
        
        .main_mem_valid_o(main_mem_valid),
        .main_mem_rd_data_o(main_mem_data)
    );

    // Check L1, L2, L3 cache hit sequentially
    assign rd_data_o = l1_cache_hit ? l1_cache_data :
                    (l2_cache_hit && l2_cache_valid) ? l2_cache_data :
                    (l3_cache_hit && l3_cache_valid) ? l3_cache_data :
                    (main_mem_valid) ? main_mem_data : 32'h0;
endmodule
