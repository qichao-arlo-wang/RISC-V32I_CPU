module data_mem (
    input  logic        clk,
    input  logic [31:0] addr_i,    // mem address
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
);

    // Memory from 0x0000 to 0x1FFFF
    localparam MEM_SIZE = 128 * 1024;
    // Top address of data memory
    localparam [31:0] TOP_ADDR = 32'h0001FFFF;

    // 128 * 1024 bytes memory
    logic [7:0] mem [MEM_SIZE-1:0];

    // Internal signal for address error detection  
    logic addr_error;

    initial begin
        $display("LOADING DATA MEMORY.");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("data.hex", mem); 
    end

    // Address range error detection
  always_comb begin
    addr_error = 1'b0; // default no error
    if (byte_en_i == 4'b0000) begin
        rd_data_o = 32'b0;
    end
        else begin
            // Check if the address is within the valid range
            if (addr_i > TOP_ADDR) begin
                addr_error = 1'b1;
                $display("Warning: address %h exceeds memory range: 0x0 to %h.", addr_i, TOP_ADDR);
            end

            // Check if the address is correctly aligned for the byte enable type
            if (byte_en_i == 4'b0001 && addr_i[0] != 1'b0) begin
                addr_error = 1'b1;
                $display("Warning: address %h is not aligned for byte access.", addr_i);
            end
            else if (byte_en_i == 4'b0011 && addr_i[1:0] != 2'b00) begin
                addr_error = 1'b1;
                $display("Warning: address %h is not aligned for half-word access.", addr_i);
            end
            else if (byte_en_i == 4'b1111 && addr_i[3:0] != 4'b0000) begin
                addr_error = 1'b1;
                $display("Warning: address %h is not aligned for word access.", addr_i);
            end

            // Validate the byte enable signal
            if (byte_en_i != 4'b0001 && byte_en_i != 4'b0011 && byte_en_i != 4'b1111) begin
                addr_error = 1'b1;
                $display("Warning: heLLO invalid byte enable: %b.", byte_en_i);
            end
        end
    end


    // Synchronous logic for both store and load
    always_ff @(posedge clk) begin
        if (byte_en_i == 4'b0000) begin
            /* verilator lint_off BLKSEQ */
            rd_data_o = 32'h0;
            /* verilator lint_on BLKSEQ */
        end
        else begin
            if (addr_error) begin
                /* verilator lint_off BLKSEQ */
                rd_data_o = 32'hDEADBEEF; // Return error value if address is invalid
                /* verilator lint_on BLKSEQ */
            end
            else begin
                // store logic
                if (wr_en_i) begin
                    case (byte_en_i)
                        // byte (8 bits)
                        4'b0001: mem[addr_i] <= wr_data_i[7:0];
                        // half word (16 bits)
                        4'b0011: begin
                            mem[addr_i]   <= wr_data_i[7:0];    // Lowest byte
                            mem[addr_i+1] <= wr_data_i[15:8];   // Highest byte
                        end
                        // word (32 bits)
                        4'b1111: begin
                            mem[addr_i]   <= wr_data_i[7:0];    // Lowest byte
                            mem[addr_i+1] <= wr_data_i[15:8];   // Next byte
                            mem[addr_i+2] <= wr_data_i[23:16];  // Higher byte
                            mem[addr_i+3] <= wr_data_i[31:24];  // Highest byte
                        end
                        default: $display("Warning: Unrecognized byte enable: %b. No data written.", byte_en_i);
                    endcase
                end
                $display("%h", {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]});
                
                case (byte_en_i)
                /* verilator lint_off BLKSEQ */
                    // byte (8 bits)
                    4'b0001: rd_data_o = {24'b0, mem[addr_i]};
                    // half word (16 bits)
                    4'b0011: rd_data_o = {16'b0, mem[addr_i+1], mem[addr_i]};
                    // word (32 bits)
                    4'b1111: rd_data_o = {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]};
                    // Return error value if byte enable is invalid
                    default: rd_data_o = 32'hDEADBEEF;
                /* verilator lint_on BLKSEQ */
                endcase
            end
        end
    end
endmodule
