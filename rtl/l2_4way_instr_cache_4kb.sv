module l2_4way_instr_cache_4kb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SETS = 256,
    parameter NUM_WAYS = 4
) (
    input  logic                   clk,
    /* verilator lint_off UNUSED */
    input  logic [ADDR_WIDTH-1:0]  addr_i,
    /* verilator lint_on UNUSED */

    input  logic                   l3_cache_valid_i,
    input  logic [DATA_WIDTH-1:0]  l3_cache_data_i,

    output logic [DATA_WIDTH-1:0]  l2_cache_data_o,
    output logic                   l2_cache_hit_o,
    output logic                   l2_cache_valid_o
);


    // Derived parameters
    localparam BYTE_OFFSET_BITS = 2; //  take lower 2 bits of the address as lower 2 tag bits
    localparam SETS_INDEX_BITS = $clog2(NUM_SETS);   // log2(256) = 8 bits
    localparam TAG_BITS = ADDR_WIDTH - SETS_INDEX_BITS - BYTE_OFFSET_BITS; // 22 bits
    
    // Cache structures
    logic [TAG_BITS-1:0] tag_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [DATA_WIDTH-1:0] data_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    logic valid_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    // Each way needs a 2-bit LRU counter
    logic [2:0] lru_bits[NUM_SETS-1:0][NUM_WAYS-1:0]; // LRU(least recently used) bits

    // Address decomposition
    logic [TAG_BITS-1:0] tag; // 22 bits
    logic [SETS_INDEX_BITS-1:0] sets_index; // 8 bits
    
    // Extract the set index and tag from the address
    assign tag        = addr_i[ADDR_WIDTH-1 : SETS_INDEX_BITS + BYTE_OFFSET_BITS]; // [31:10] (22 bits)
    assign sets_index = addr_i[SETS_INDEX_BITS + BYTE_OFFSET_BITS - 1 : BYTE_OFFSET_BITS]; // [9:2] (8 bits)

    // Internal signals
    logic [NUM_WAYS-1:0] way_hit_flag;
    logic hit_detected;

    // initialize cache arrays
    initial begin
        for (int s = 0; s < NUM_SETS; s++) begin
            for (int w = 0; w < NUM_WAYS; w++) begin
                valid_array[s][w] = 1'b0;
                lru_bits[s][w] = '0;
                tag_array[s][w] = '0;
                data_array[s][w] = '0;
            end
        end
    end

    always_comb begin
        hit_detected = 1'b0;
        way_hit_flag = '0;
        l2_cache_data_o = '0;
        l2_cache_valid_o = 1'b0;  // Default to invalid

        for (int i = 0; i < NUM_WAYS; i++) begin
                // Check if the cache line is valid and the tags match
                if (!hit_detected && valid_array[sets_index][i] && tag_array[sets_index][i] == tag) begin
                    hit_detected     = 1'b1;   // Mark as a hit
                    way_hit_flag[i]  = 1'b1;   // Mark the hit way
                    l2_cache_valid_o = 1'b1;   // Mark as valid

                    // read the data from the hit way
                    l2_cache_data_o = data_array[sets_index][i][31:0];

                end
            end
    end

    assign l2_cache_hit_o = hit_detected;

    // Syncronous cache update, LRU and miss fill
    always_ff @(posedge clk) begin
        // // // IF HIT DETECTED // // //
        if (hit_detected) begin
            // On hit: update LRU
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (way_hit_flag[i]) begin
                    // Hit way is most recently used
                    lru_bits[sets_index][i] <= '0;
                end
                else begin
                    // Increment LRU count for others (only if less than NUM_WAYS-1)
                    if (lru_bits[sets_index][i] < (NUM_WAYS-1))
                        lru_bits[sets_index][i] <= lru_bits[sets_index][i] + 1;
                end
            end
        end

        // // // IF MISS // // //
        else if (l3_cache_valid_i) begin
            int evict_way = 0;
            logic [2:0] max_lru = lru_bits[sets_index][0];

            // Find the way with the highest LRU count
            for (int i = 1; i < NUM_WAYS; i++) begin
                // Find the way with the highest LRU count
                if (lru_bits[sets_index][i] > max_lru) begin
                    max_lru = lru_bits[sets_index][i];
                    evict_way = i;
                end
            end

            tag_array[sets_index][evict_way]   <= tag;
            data_array[sets_index][evict_way] <= l3_cache_data_i;
            valid_array[sets_index][evict_way] <= 1'b1;

            // Update LRU bits: new line is most recently used = 0
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (i == evict_way) begin
                    lru_bits[sets_index][i] <= 0;
                end
                // Increment LRU count for others (only if less than NUM_WAYS-1)
                else begin
                    if (lru_bits[sets_index][i] < (NUM_WAYS-1))
                        lru_bits[sets_index][i] <= lru_bits[sets_index][i] + 1;
                end
            end
        end
    end

endmodule
