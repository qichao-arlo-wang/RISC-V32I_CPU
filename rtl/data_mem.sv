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
    // 128kb memory
    logic [7:0] mem [0:MEM_SIZE-1];

    initial begin
        $display("Loading datamem.");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("data_mem_test.hex", mem); 
    end

    // Internal signal for address error detection  
    logic addr_error;

    // Address range error detection
    always_comb begin
        addr_error = 1'b0; // default no error
        case (byte_en_i)
            // byte (8 bits)
            0b0001: begin
                if (addr_i > MEM_SIZE - 1) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the value range: %h.", addr_i);
                end
            end
            // half word (16 bits)
            0b0011: begin
                if (addr_i > MEM_SIZE - 2) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the value range: %h.", addr_i);
                end
            end
            // word (32 bits)
            0b1111: begin
                if (addr_i > MEM_SIZE - 3) begin
                    addr_error = 1'b1;
                    $display("Warning: address not in the value range: %h.", addr_i);
                end
            end
            default: begin
                addr_error = 1'b1;
                $display("Warning: invalid byte enable: %b.", byte_en_i);
            end
        endcase
    end

    // store logic
    always_ff @(posedge clk) begin
        if (addr_error) begin
            rd_data_o = 32'hDEADBEEF; // Return error value if address is invalid
        end
        else if (wr_en_i) begin
            case (byte_en_i)
                // byte (8 bits)
                0b0001: begin
                    mem[addr_i] <= wr_data_i[7:0];
                end

                // half word (16 bits)
                0b0011: begin
                    mem[addr_i+1]   <= wr_data_i[7:0];    // Lowest byte
                    mem[addr_i] <= wr_data_i[15:8];   // Highest byte
                end

                // word (32 bits)
                0b1111: begin
                    mem[addr_i+3] <= wr_data_i[7:0];    // Lowest byte
                    mem[addr_i+2] <= wr_data_i[15:8];   // Next byte
                    mem[addr_i+1] <= wr_data_i[23:16];  // Higher byte
                    mem[addr_i]   <= wr_data_i[31:24];  // Highest byte
                end
            endcase
        end
    end

    // load logic
    always_comb begin
        if (addr_error) begin
            rd_data_o = 32'hDEADBEEF; // Return error value if address is invalid
        end
        else begin
            case (byte_en_i)
                // byte (8 bits)
                0b0001: begin
                    rd_data_o = {24'b0, mem[addr_i]};
                end
                // half word (16 bits)
                0b0011: begin
                    rd_data_o = {16'b0, mem[addr_i], mem[addr_i+1]};
                end
                // word (32 bits)
                0b1111: begin
                    rd_data_o = {mem[addr_i], mem[addr_i+1], mem[addr_i+2], mem[addr_i+3]};
                end
            endcase
        end
    end
endmodule
