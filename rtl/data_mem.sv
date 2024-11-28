module data_mem (
    input  logic        clk,
    input  logic [31:0] addr_i,    // mem address
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
);

    // Memory from 0x0000 to 0x1FFFF
    localparam int MEM_SIZE = 128 * 1024;
    // Top address of data memory
    localparam logic [31:0] TOP_ADDR = 32'h0001FFFF;

    // 128 * 1024 bytes memory
    logic [7:0] mem [0:MEM_SIZE-1];

    // Internal signal for address error detection  
    logic addr_error;

    // local address
    logic [31:0] local_addr;

    initial begin
        $display("LOADING DATA MEMORY.");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("data_mem_test.hex", mem); 
    end


    // Address range error detection
    always_comb begin
        addr_error = 1'b0; // default no error
        case (byte_en_i)
            // byte (8 bits)
            4'b0001: begin
                if (addr_i > TOP_ADDR - 1) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the valid range: %h.", addr_i);
                end
            end
            // half word (16 bits)
            4'b0011: begin
                if (addr_i > TOP_ADDR - 2) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the valid range: %h.", addr_i);
                end
            end
            // word (32 bits)
            4'b1111: begin
                if (addr_i > TOP_ADDR - 4) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the valid range: %h.", addr_i);
                end
            end
            default: begin
                addr_error = 1'b1;
                $display("Warning: invalid byte enable: %b.", byte_en_i);
            end
        endcase
    end

    // Synchronous logic for both store and load
    always_ff @(posedge clk) begin
        local_addr <= {15'b0, addr_i[16:0]};
        if (addr_error) begin
            rd_data_o <= 32'hDEADBEEF; // Return error value if address is invalid
        end
        else begin
            // store logic
            if (wr_en_i) begin
                case (byte_en_i)
                    // byte (8 bits)
                    4'b0001: mem[local_addr] <= wr_data_i[7:0];
                    // half word (16 bits)
                    4'b0011: begin
                        mem[local_addr]   <= wr_data_i[7:0];    // Lowest byte
                        mem[local_addr+1] <= wr_data_i[15:8];   // Highest byte
                    end
                    // word (32 bits)
                    4'b1111: begin
                        mem[local_addr]   <= wr_data_i[7:0];    // Lowest byte
                        mem[local_addr+1] <= wr_data_i[15:8];   // Next byte
                        mem[local_addr+2] <= wr_data_i[23:16];  // Higher byte
                        mem[local_addr+3] <= wr_data_i[31:24];  // Highest byte
                    end
                    default: $display("Warning: Unrecognized byte enable: %b. No data written.", byte_en_i);
                endcase
            end

            case (byte_en_i)
                // byte (8 bits)
                4'b0001: rd_data_o <= {24'b0, mem[local_addr]};
                // half word (16 bits)
                4'b0011: rd_data_o <= {16'b0, mem[local_addr+1], mem[local_addr]};
                // word (32 bits)
                4'b1111: rd_data_o <= {mem[local_addr+3], mem[local_addr+2], mem[local_addr+1], mem[local_addr]};
                // Return error value if byte enable is invalid
                default: rd_data_o <= 32'hDEADBEEF;
            endcase
        end
    end
endmodule
