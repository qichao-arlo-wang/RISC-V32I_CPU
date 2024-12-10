module instr_cache_hierarchy #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [DATA_WIDTH-1:0] main_mem_instr,

    output logic [DATA_WIDTH-1:0] instr_o,
    output logic                  cache_hit_l1,
    output logic                  cache_hit_l2,
    output logic                  cache_hit_l3
);

    logic [DATA_WIDTH-1:0] l1_instr, l2_instr, l3_instr;
    logic                  l1_miss_o, l2_miss_o;

    // L1 Cache
    l1_4way_instr_cache_4kb l1_cache (
        .clk(clk),
        .addr_i(addr_i),
        .l2_instr_i(l2_instr),
        .instr_o(l1_instr),
        .cache_hit_o(cache_hit_l1),
        .l1_miss_o(l1_miss_o)
    );

    // L2 Cache
    l2_4way_instr_cache_16kb l2_cache (
        .clk(clk),
        .addr_i(addr_i),
        .l3_instr_i(l3_instr),
        .instr_o(l2_instr),
        .cache_hit_o(cache_hit_l2),
        .l2_miss_o(l2_miss_o)
    );

    // L3 Cache
    l3_4way_instr_cache_64kb l3_cache (
        .clk(clk),
        .addr_i(addr_i),
        .main_mem_instr(main_mem_instr),
        .instr_o(l3_instr),
        .cache_hit_o(cache_hit_l3)
    );

    always_comb begin
        if (cache_hit_l1) begin
            instr_o = l1_instr;
        end else if (cache_hit_l2) begin
            instr_o = l2_instr;
        end else if (cache_hit_l3) begin
            instr_o = l3_instr;
        end else begin
            instr_o = main_mem_instr;
        end
    end

    always_ff @(posedge clk) begin
        $display("Time: %0t, Addr: %h, L1 Miss: %b, L2 Miss: %b, L1 Hit: %b, L2 Hit: %b, L3 Hit: %b, Instr: %h",
         $time, addr_i, l1_miss_o, l2_miss_o, cache_hit_l1, cache_hit_l2, cache_hit_l3, instr_o);
    end

endmodule
