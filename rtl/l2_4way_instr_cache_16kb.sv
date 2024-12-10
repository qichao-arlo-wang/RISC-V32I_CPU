module l2_4way_instr_cache_16kb #(
    parameter ADDR_WIDTH = 32,     // Address width
    parameter DATA_WIDTH = 32,     // Data width (instruction size)
    parameter NUM_SETS = 512,      // Number of sets for 4KB / 4 ways / 4 bytes per line
    parameter NUM_WAYS = 8         // Number of ways per set
) (
    input logic                  clk,               // Clock signal
    /* verilator lint_off UNUSED */
    input logic [ADDR_WIDTH-1:0] addr_i,
    /* verilator lint_on UNUSED */
    input logic [DATA_WIDTH-1:0] l3_instr_i,


    output logic [DATA_WIDTH-1:0]  instr_o,           // Instruction read out
    output logic                   cache_hit_o,        // Indicates a cache hit
    output logic                   l2_miss_o
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

    initial begin
        for (int s = 0; s < NUM_SETS; s++) begin
            for (int w = 0; w < NUM_WAYS; w++) begin
                valid_array[s][w] = 1'b0;
                tag_array[s][w] = '0;
                instr_array[s][w] = '0;
            end
        end
    end

    // Cache lookup logic
    always_comb begin
        l2_miss_o = 1'b1;
        cache_hit_o = 1'b0;
        instr_o = 32'hDEADBEEF; // Default invalid
        
        for (int i = 0; i < NUM_WAYS; i++) begin
            if (valid_array[set_index][i] && (tag_array[set_index][i] == tag)) begin
                cache_hit_o = 1'b1;
                l2_miss_o = 1'b0;
                instr_o = instr_array[set_index][i];
            end
        end
    end

    always_ff @(posedge clk) begin
        if (l2_miss_o) begin
            // On an L2 miss, fetch from L3 and update the L2 cache
            int evict_way = 0;
            int max_lru = int'(lru_bits[set_index][0]);
            for (int i = 1; i < NUM_WAYS; i++) begin
                if (int'(lru_bits[set_index][i]) > max_lru) begin
                    max_lru = int'(lru_bits[set_index][i]);
                    evict_way = i;
                end
            end

            tag_array[set_index][evict_way]   <= tag;
            instr_array[set_index][evict_way] <= l3_instr_i;
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
