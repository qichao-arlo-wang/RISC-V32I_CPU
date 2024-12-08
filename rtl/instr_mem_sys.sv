module instr_mem_sys (
    input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,
    /* verilator lint_off UNUSED */
    output logic [31:0] instr_o
);

    logic [31:0] l1_instr, l2_instr, l3_instr, mem_instr;
    logic l1_hit, l2_hit, l3_hit;

    // Instantiate caches and memory
    l1_4way_instr_cache_4kb l1_icache (
        .clk(clk),
        .addr_i(addr_i),
        .main_mem_instr(l2_instr), // On L1 miss, data should eventually come from L2
        .instr_o(l1_instr),
        .cache_hit_o(l1_hit)
    );

    l2_4way_instr_cache_16kb l2_icache (
        .clk(clk),
        .addr_i(addr_i), // For simplicity, same addr_i. Real design may need a FSM.
        .main_mem_instr(l3_instr),
        .instr_o(l2_instr),
        .cache_hit_o(l2_hit)
    );

    l3_4way_instr_cache_64kb l3_icache (
        .clk(clk),
        .addr_i(addr_i),
        .main_mem_instr(mem_instr),
        .instr_o(l3_instr),
        .cache_hit_o(l3_hit)
    );

    instr_mem main_memory_inst (
        .addr_i(addr_i),
        .instr_o(mem_instr)
    );

    // Check L1 hit first
    // if !l1_hit => Check L2 hit
    // if !l2_hit => Check L3 hit
    // if !l3_hit => use mem_instr
    
    always_comb begin
        if (l1_hit) begin
            instr_o = l1_instr;
        end else if (l2_hit) begin
            instr_o = l2_instr;
        end else if (l3_hit) begin
            instr_o = l3_instr;
        end else begin
            instr_o = mem_instr;
        end
    end

    // - On L1 miss, request data from L2. If L2 also misses, request from L3, etc.
    // - On a hit in L2/L3/mem, write-back to upper caches.

endmodule
