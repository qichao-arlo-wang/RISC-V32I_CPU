module instr_mem (
    input  logic [31:0] addr_i,   // Address (Program Counter)
    output logic [31:0] instr_o   // Fetched instruction
);

    localparam        MEM_SIZE  = 4 * 1024;             // Memory size in bytes (0xBFC00000 to 0xBFC00FFF -> 4KB)
    localparam [31:0] BASE_ADDR = 32'hBFC00000;         // Base address of instruction memory
    localparam [31:0] TOP_ADDR  = 32'hBFC00FFF;         // Top address of instruction memory
    localparam string MEM_FILE  = "program.hex";        // Memory initialization file

    // 4 x 1024 bytes memory
    logic [7:0] mem [0:MEM_SIZE-1];

    // Internal signal for address error detection
    logic addr_error;

    // Initialize memory
    initial begin
        $display("LOADING INSTRUCTION MEMORY...");
        
        // The default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh(MEM_FILE, mem); 
    end

    logic [31:0] local_addr;

    // Address error detection logic
    always_comb begin
        addr_error = 1'b0; // Default: no error
        // Address alignment and range checking
        if (addr_i < BASE_ADDR || addr_i > TOP_ADDR) begin
            addr_error = 1'b1;
            $display("Warning: Address out of range: %h.", addr_i);
        end 
        else if (addr_i[1:0] != 2'b00) begin
            addr_error = 1'b1;
            $display("Warning: Unaligned address detected: %h.", addr_i);
        end
    end

    // Read logic: fetch instruction
    always_comb begin
        instr_o = 32'hDEADBEEF; // Default value
        if (addr_error) begin
            // Return error value if address is invalid
            local_addr = 32'h0;
            instr_o = 32'hDEADBEEF;
        end 
        else begin
            // Calculate local memory address offset by subtracting BASE_ADDR
            local_addr = {20'h0, addr_i[11:0]};  // addr_i - BASE_ADDR assumes addr_i is within valid range
            instr_o = {mem[local_addr + 3], mem[local_addr + 2], mem[local_addr + 1], mem[local_addr]};
        end
    end 
endmodule
