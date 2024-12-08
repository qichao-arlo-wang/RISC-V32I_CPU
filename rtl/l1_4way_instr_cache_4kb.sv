module l1_4way_instr_cache_4kb #(
    parameter ADDR_WIDTH = 32,     // Address width
    parameter DATA_WIDTH = 32,     // Data width (instruction size)
    parameter NUM_SETS = 256,      // Number of sets for 4KB / 4 ways / 4 bytes per line
    parameter NUM_WAYS = 4         // Number of ways per set
) (
    input  logic                   clk,               // Clock signal
    input  logic [ADDR_WIDTH-1:0]  addr_i,            // Instruction address
    input  logic [DATA_WIDTH-1:0]  main_mem_instr,    // Instruction word from main memory

    output logic [DATA_WIDTH-1:0]  instr_o,           // Instruction read out
    output logic                   cache_hit_o        // Indicates a cache hit
);

    /* 
        4-way set-associative instruction cache:

        Memory address breakdown (32 bits):
        |   Tag (22 bits) | Set index (8 bits) | Byte offset (2 bits) |
        | a[31:10]        | a[9:2]            | 00                   |

        Each cache line stores one 32-bit instruction.
        The cache line structure per way:
        | valid | tag (22 bits) | instruction (32 bits) |

        LRU bits: 2-3 bits per set for 4 ways, but we can use the same scheme as data cache.
    */

    // Derived parameters
    localparam BYTE_OFFSET_BITS = 2; 
    localparam SET_INDEX_BITS = $clog2(NUM_SETS); // log2(256) = 8
    localparam TAG_BITS = ADDR_WIDTH - SET_INDEX_BITS - BYTE_OFFSET_BITS; // 22 bits

    // Cache arrays
    logic [TAG_BITS-1:0]       tag_array   [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [DATA_WIDTH-1:0]     instr_array [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic                       valid_array [NUM_SETS-1:0][NUM_WAYS-1:0];
    logic [2:0]                lru_bits    [NUM_SETS-1:0][NUM_WAYS-1:0]; // LRU counters

    // Address decomposition
    logic [TAG_BITS-1:0]       tag;
    logic [SET_INDEX_BITS-1:0] set_index;

    assign tag       = addr_i[ADDR_WIDTH-1 : SET_INDEX_BITS + BYTE_OFFSET_BITS]; // top bits for tag
    assign set_index = addr_i[SET_INDEX_BITS + BYTE_OFFSET_BITS - 1 : BYTE_OFFSET_BITS]; // next bits for set index

    // Internal signals
    logic [NUM_WAYS-1:0] way_hit_flag;
    logic                hit_detected;

    initial begin
        for (int s = 0; s < NUM_SETS; s++) begin
            for (int w = 0; w < NUM_WAYS; w++) begin
                valid_array[s][w] = 1'b0;
                lru_bits[s][w] = '0;
            end
        end
    end

    // Lookup and read logic
    always_comb begin
        hit_detected = 1'b0;
        way_hit_flag = '0;
        instr_o = 32'hDEADBEEF; // Default invalid

        for (int i = 0; i < NUM_WAYS; i++) begin
            if (valid_array[set_index][i] && (tag_array[set_index][i] == tag)) begin
                hit_detected   = 1'b1;
                way_hit_flag[i] = 1'b1;
                instr_o        = instr_array[set_index][i];
            end
        end
    end

    assign cache_hit_o = hit_detected;

    // On clock edge, update cache lines and LRU
    always_ff @(posedge clk) begin
        if (hit_detected) begin
            // Update LRU on hit
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (way_hit_flag[i]) begin
                    // Hit way is most recently used
                    lru_bits[set_index][i] <= '0;
                end else begin
                    // Increment LRU for others if less than NUM_WAYS-1
                    if (lru_bits[set_index][i] < (NUM_WAYS-1))
                        lru_bits[set_index][i] <= lru_bits[set_index][i] + 1;
                end
            end
        end else begin
            // Miss: replace LRU line
            int evict_way = 0;
            int max_lru = lru_bits[set_index][0];
            for (int i = 1; i < NUM_WAYS; i++) begin
                if (int'(lru_bits[set_index][i]) > max_lru) begin
                    max_lru = int'(lru_bits[set_index][i]);
                    evict_way = i;
                end
            end

            // Replace evicted line with main_mem_instr
            tag_array[set_index][evict_way]   <= tag;
            instr_array[set_index][evict_way] <= main_mem_instr;
            valid_array[set_index][evict_way] <= 1'b1;

            // Update LRU: new line is recently used
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (i == evict_way) begin
                    lru_bits[set_index][i] <= '0;
                end else begin
                    if (lru_bits[set_index][i] < (NUM_WAYS-1))
                        lru_bits[set_index][i] <= lru_bits[set_index][i] + 1;
                end
            end
        end
    end

endmodule
