module data_mem (
    input  logic        clk,
    input  logic [31:0] addr_i,    // mem address
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
);
    
    localparam int MEM_SIZE = 1024;
    // 1024 x 8-bit memory
    logic [7:0] mem [0:MEM_SIZE*4-1];

    initial begin
        $display("Loading datamem.");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("data_mem_test.hex", mem); 
    end

    // Internal signal for address error detection  
    logic addr_error;

    // Address alignment and range error detection
    always_comb begin
        addr_error = 1'b0; // default no error
        // Check for 4-byte alignment
        if ((addr_i[1:0] != 2'b00) != 0) begin
            addr_error = 1'b1; // Address misalignment
            $display("Warning: Unaligned address detected: %h.", addr_i);
        end
        
        // Check if address is within valid range
        else if (addr_i > MEM_SIZE - 3) begin
            addr_error = 1'b1; // Address out of range
            $display("Warning: address not in the value range: %h.", addr_i);
        end
    end


  // Write logic
    always_ff @(posedge clk) begin
        if (wr_en_i && !addr_error) begin
            mem[addr_i+3]   <= byte_en_i[0] ? wr_data_i[7:0]   : 8'b0; // Lowest byte
            mem[addr_i+2] <= byte_en_i[1] ? wr_data_i[15:8]  : 8'b0; // Next byte
            mem[addr_i+1] <= byte_en_i[2] ? wr_data_i[23:16] : 8'b0; // Higher byte
            mem[addr_i] <= byte_en_i[3] ? wr_data_i[31:24] : 8'b0; // Highest byte
        end
    end

    // Read logic
    // Combine 4 bytes to form a 32-bit data
    always_comb begin
        if (addr_error) begin
            rd_data_o = 32'hDEADBEEF; // Return error value if address is invalid
        end 
        else begin
            rd_data_o = {mem[addr_i], mem[addr_i+1], mem[addr_i+2], mem[addr_i+3]};
        end
    end

endmodule
