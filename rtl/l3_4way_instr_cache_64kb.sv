module l3_4way_instr_cache_64kb #(
    parameter ADDR_WIDTH = 32,     // Address width
    parameter DATA_WIDTH = 32,     // Data width (instruction size)
    parameter NUM_SETS = 1024,      // Number of sets for 4KB / 4 ways / 4 bytes per line
    parameter NUM_WAYS = 16         // Number of ways per set
) (
    input  logic                   clk,               // Clock signal
    /* verilator lint_off UNUSED */
    input logic [ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSED */
    input  logic [DATA_WIDTH-1:0]  main_mem_instr,    // Instruction word from main memory

    output logic [DATA_WIDTH-1:0]  instr_o,           // Instruction read out
    output logic                   cache_hit_o        // Indicates a cache hit
);

    localparam BYTE_OFFSET_BITS = 2; 
    localparam SET_INDEX_BITS = $clog2(NUM_SETS);
    localparam TAG_BITS = ADDR_WIDTH - SET_INDEX_BITS - BYTE_OFFSET_BITS + 2;

    logic [TAG_BITS-1:0]       tag_array   [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [DATA_WIDTH-1:0]     instr_array [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic                      valid_array [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [2:0]                lru_bits    [NUM_SETS-1:0][NUM_WAYS-1:0];

    logic [TAG_BITS-1:0]       tag;
    logic [SET_INDEX_BITS-1:0] set_index;

    assign tag       = {addr_i[ADDR_WIDTH-1 : SET_INDEX_BITS + BYTE_OFFSET_BITS], addr_i[SET_INDEX_BITS + BYTE_OFFSET_BITS - 1 : SET_INDEX_BITS + BYTE_OFFSET_BITS - 2]};
    assign set_index = addr_i[SET_INDEX_BITS + BYTE_OFFSET_BITS - 1 : BYTE_OFFSET_BITS];
   
    logic [DATA_WIDTH-1:0] instr_cache_data;

    initial begin
        for (int s = 0; s < NUM_SETS; s++) begin
            for (int w = 0; w < NUM_WAYS; w++) begin
                valid_array[s][w] = 1'b0;
                tag_array[s][w] = '0;
                instr_array[s][w] = '0;
            end
        end
    end

    always_comb begin
        cache_hit_o = 1'b0;
        instr_cache_data = 32'hDEADBEEF;
        instr_o = main_mem_instr;

        for (int i = 0; i < NUM_WAYS; i++)begin
            if (valid_array[set_index][i] && (tag_array[set_index][i] == tag)) begin
                cache_hit_o      = 1'b1;
                instr_cache_data = instr_array[set_index][i];
            end
        end
        if (cache_hit_o) begin
            instr_o = instr_cache_data;
        end
    end

    always_ff @(posedge clk) begin
        if (!cache_hit_o) begin
            // On an L3 miss, fetch from main memory and update the L3 cache
            int evict_way = 0;
            int max_lru = int'(lru_bits[set_index][0]);
            for (int i = 1; i < NUM_WAYS; i++) begin
                if (int'(lru_bits[set_index][i]) > max_lru) begin
                    max_lru = int'(lru_bits[set_index][i]);
                    evict_way = i;
                end
            end

            tag_array[set_index][evict_way]   <= tag;
            instr_array[set_index][evict_way] <= main_mem_instr;
            valid_array[set_index][evict_way] <= 1'b1;

            // Update LRU
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (i == evict_way)
                    lru_bits[set_index][i] <= '0;
                else if (int'(lru_bits[set_index][i]) < int'(NUM_WAYS-1))
                    lru_bits[set_index][i] <= lru_bits[set_index][i] + 1;
            end
        end
    end

endmodule
