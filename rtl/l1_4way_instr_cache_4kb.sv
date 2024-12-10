module l1_4way_instr_cache_4kb #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SETS = 256,
    parameter NUM_WAYS = 4
) (
    input  logic                   clk,
    input  logic [ADDR_WIDTH-1:0]  addr_i,
    input  logic [DATA_WIDTH-1:0]  main_mem_instr,
    output logic [DATA_WIDTH-1:0]  instr_o,
    output logic                   cache_hit_o
);

/*
    Instruction Cache Memory Address Breakdown
    ==========================================
    Memory Address (32 bits):
    |  Tag (22 bits)   | Set Index (8 bits) | Byte Offset (2 bits) |
    | addr_i[31:10]    | addr_i[9:2]        | addr_i[1:0]          |

    - **Tag (22 bits)**: Used to match the requested memory address with the stored cache data
    - **Set Index (8 bits)**: Determines the specific cache set
    - **Byte Offset (2 bits)**: Identifies the byte within a cache line

    Cache Line Structure Per Way
    ============================
    - **Valid Bit** (1 bit): Indicates if the cache line contains valid data
    - **Tag** (22 bits): For cached address
    - **Instruction (Data)** (32 bits):  Cached instruction word
    - **LRU** (3 bits): Least Recently Used counter for replacement 

    Example Cache Line for One Way:
    ---------------------------------
    | Valid | Tag        | Instruction    | LRU |
    |   1   | 0xBFC0     | 0x0FF00313     |  0  |

    Cache Set Example (4-Way Associative Cache):
    --------------------------------------------
    | Way   | Valid | Tag    | Instruction  | LRU |
    |-------|-------|--------|--------------|-----|
    | Way 0 |   1   | 0xBFC0 | 0x0FF00313   |  0  |
    | Way 1 |   0   | 0x0000 | 0xDEADBEEF   |  3  |
    | Way 2 |   0   | 0x0000 | 0xDEADBEEF   |  2  |
    | Way 3 |   0   | 0x0000 | 0xDEADBEEF   |  1  |
*/


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

    logic [NUM_WAYS-1:0] way_hit_flag;
    logic                hit_detected;

    initial begin
        for (int s = 0; s < NUM_SETS; s++) begin
            for (int w = 0; w < NUM_WAYS; w++) begin
                valid_array[s][w] = 1'b0;
                lru_bits[s][w] = '0;
                tag_array[s][w] = '0;
                instr_array[s][w] = '0;
            end
        end
    end

    always_comb begin
        hit_detected = 1'b0;
        way_hit_flag = '0;
        instr_o = 32'hDEADBEEF;

        for (int i = 0; i < NUM_WAYS; i++) begin
            if (valid_array[set_index][i] && (tag_array[set_index][i] == tag)) begin
                hit_detected   = 1'b1;
                way_hit_flag[i] = 1'b1;
                instr_o        = instr_array[set_index][i];
            end
        end
        $display("ADDR: %h, CACHE_HIT: %b, DATA: %h", addr_i, cache_hit_o, instr_o);
    end

    assign cache_hit_o = hit_detected;

    always_ff @(posedge clk) begin
        if (hit_detected) begin
            for (int i = 0; i < NUM_WAYS; i++) begin
                if (way_hit_flag[i]) lru_bits[set_index][i] <= '0;
                else if (lru_bits[set_index][i] < NUM_WAYS-1) lru_bits[set_index][i] <= lru_bits[set_index][i] + 1;
            end
        end else begin
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

            for (int i = 0; i < NUM_WAYS; i++) begin
                if (i == evict_way) lru_bits[set_index][i] <= '0;
                else if (lru_bits[set_index][i] < NUM_WAYS-1) lru_bits[set_index][i] <= lru_bits[set_index][i] + 1;
            end
        end
    end

endmodule
