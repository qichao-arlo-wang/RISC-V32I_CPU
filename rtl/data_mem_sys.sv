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

    logic cache_hit;
    logic [31:0] l1_cache_data;
    logic [31:0] main_mem_data;

    // Instantiate the L1 Cache
    l1_4way_cache_4kb L1_cache (
        .clk(clk),
        .wr_en_i(wr_en_i),
        .addr_i(addr_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),
        .main_mem_data(main_mem_data),

        .l1_rd_data_o(l1_cache_data),
        .cache_hit_o(cache_hit)
    );

    // Instantiate the Data Memory
    data_mem data_memory_inst (
        .clk(clk),
        .addr_i(addr_i),
        .wr_en_i(wr_en_i),
        .wr_data_i(wr_data_i),
        .byte_en_i(byte_en_i),
        
        .main_mem_rd_data_o(main_mem_data)
    );

    assign rd_data_o = cache_hit ? l1_cache_data : main_mem_data;
endmodule
