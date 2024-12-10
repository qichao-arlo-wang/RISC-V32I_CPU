module l3_8way_cache_8kb #(
    parameter ADDR_WIDTH = 32,     // Address width
    parameter DATA_WIDTH = 32,     // Data width
    // parameter BLOCK_SIZE = 4,      // Cache block size (4 bytes)
    parameter NUM_SETS = 256,      // Number of sets (calculated from 8k bytes / 8-way)
    parameter NUM_WAYS = 8         // Number of ways per set
) (
    input logic                   clk,                  // Clock signal
    // input logic                   rst,               // Reset signal
    input logic                   wr_en_i,              // Write enable
    /* verilator lint_off UNUSED */
    input logic [ADDR_WIDTH-1:0]  addr_i,               // Memory address
    /* verilator lint_on UNUSED */
    input logic [DATA_WIDTH-1:0]  wr_data_i,            // Data to write
    input logic [3:0]             byte_en_i,            // byte enable
    input logic                   main_mem_valid_i,     // Main memory data valid
    input logic [DATA_WIDTH-1:0]  main_mem_data_i,      // Data from main memory

    output logic                  l3_cache_valid_o,     // Indicates a cache hit
    output logic [DATA_WIDTH-1:0] l3_rd_data_o,         // Data read
    output logic                  l3_cache_hit_o        // Indicates a cache hit
);

    /* 8-way set-associative cache 
        Cache structure:
        |       way1        |       way2        |       way3        |       way4        |   ... ...    
        |  v  | tag  | data |  v  | tag  | data |  v  | tag  | data |  v  | tag  | data |   ... ...
        | [1] | [24] | [32] | [1] | [24] | [32] | [1] | [24] | [32] | [1] | [24] | [32] |   ... ...
        
        Memory address (32 bits):
            | higher tag bits | set index | lower tag bits |
            |       [22]      |    [8]    |        [2]     |
            |  addr_i[31:10]  |   a[9:2]  |      a[1:0]    |
    */

    // Derived parameters
    localparam LOWER_TAG_BITS = 2; //  take lower 2 bits of the address as lower 2 tag bits
    localparam SETS_INDEX_BITS = $clog2(NUM_SETS);   // log2(256) = 8 bits
    localparam TAG_BITS = ADDR_WIDTH - SETS_INDEX_BITS; // 22 bits + 2 lower bits = 24 bits
    
    // Cache structures
    logic [TAG_BITS-1:0] tag_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [DATA_WIDTH-1:0] data_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    logic valid_array[NUM_SETS-1:0][NUM_WAYS-1:0];
    // Each way needs a 2-bit LRU counter
    logic [2:0] lru_bits[NUM_SETS-1:0][NUM_WAYS-1:0]; // LRU(least recently used) bits

    // Address decomposition
    logic [TAG_BITS-1:0] tag; // 24 bits
    logic [SETS_INDEX_BITS-1:0] sets_index; // 8 bits
    
    // Extract the set index and tag from the address
    assign tag        = {addr_i[ADDR_WIDTH-1 : SETS_INDEX_BITS + LOWER_TAG_BITS], addr_i[LOWER_TAG_BITS-1:0]}; // [31:10] + [1:0] (24 bits)
    assign sets_index = addr_i[SETS_INDEX_BITS + LOWER_TAG_BITS - 1 : LOWER_TAG_BITS]; // [9:2] (8 bits)
    
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

    // Cache lookup and read logic 
    always_comb begin
        hit_detected = 1'b0;      // Default: no cache hit
        way_hit_flag = '0;        // Default: no way is hit
        l3_rd_data_o = '0;        // Default: no data output
        l3_cache_valid_o = 1'b0;  // Default: no valid data

        if (byte_en_i != 0) begin
            // find the way that was hit
            for (int i = 0; i < NUM_WAYS; i++) begin
                // Check if the cache line is valid and the tags match
                if (!hit_detected && valid_array[sets_index][i] && tag_array[sets_index][i] == tag) begin
                    hit_detected = 1'b1;      // Mark as a hit
                    way_hit_flag[i] = 1'b1;   // Mark the hit way
                    l3_cache_valid_o = 1'b1;  // Mark the data as valid
                    // read the data from the hit way
                    case (byte_en_i)
                        4'b0001: l3_rd_data_o = {24'b0, data_array[sets_index][i][7:0]};
                        4'b0011: l3_rd_data_o = {16'b0, data_array[sets_index][i][15:0]};
                        4'b1111: l3_rd_data_o = data_array[sets_index][i][31:0];
                        default: $display("Warning: Unrecognized byte enable: %b. No data read.", byte_en_i);
                    endcase
                end
            end
        end
    end
    
    assign l3_cache_hit_o = hit_detected;

    // Synchronous update of cache arrays, LRU and handle miss fill
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
                    if (lru_bits[sets_index][i] < 3'(NUM_WAYS-1))
                        lru_bits[sets_index][i] <= lru_bits[sets_index][i] + 1;
                end
            end

            // If it's a write operation on a hit line, update the data
            if (wr_en_i) begin
                // find the way that was hit
                for (int i = 0; i < NUM_WAYS; i++) begin
                    // write the data to the hit way
                    if (way_hit_flag[i]) begin
                        case (byte_en_i)
                            4'b0001: data_array[sets_index][i][7:0]  <= wr_data_i[7:0];
                            4'b0011: data_array[sets_index][i][15:0] <= wr_data_i[15:0];
                            4'b1111: data_array[sets_index][i]       <= wr_data_i;
                            default: $display("Warning: Unrecognized byte enable: %b. No data written.", byte_en_i);
                        endcase
                    end
                end
            end
        end

        // // // IF MISS // // //
        else if (main_mem_valid_i) begin
            // Cache miss: Replace the LRU line
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

            // Replace the evicted line
            tag_array[sets_index][evict_way]   <= tag;
            valid_array[sets_index][evict_way] <= 1'b1;
            if (wr_en_i) begin
                // Write with byte masking
                case (byte_en_i)
                    4'b0001: data_array[sets_index][evict_way] <= {main_mem_data_i[31:8], wr_data_i[7:0]};
                    4'b0011: data_array[sets_index][evict_way] <= {main_mem_data_i[31:16], wr_data_i[15:0]};
                    4'b1111: data_array[sets_index][evict_way] <= wr_data_i;
                    default: $display("Warning: Unrecognized byte enable: %b. No data written.", byte_en_i);
                endcase
            end 
            // Read operation: Load main memory data when not writing
            else begin
                data_array[sets_index][evict_way] <= main_mem_data_i;
            end


            // Update LRU bits: new line is most recently used = 0
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (i == evict_way) begin
                    lru_bits[sets_index][i] <= 0;
                end 
                // Increment LRU count for others (only if less than NUM_WAYS-1)
                else begin
                    if (lru_bits[sets_index][i] < 3'(NUM_WAYS-1))
                        lru_bits[sets_index][i] <= lru_bits[sets_index][i] + 1;
                end
            end
        end
    end
endmodule
