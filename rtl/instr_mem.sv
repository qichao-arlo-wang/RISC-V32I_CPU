module instr_mem (
    input  logic [31:0] addr_i,   // Address (Program Counter)
    output logic [31:0] instr_o   // Fetched instruction
);

    localparam int          MEM_SIZE  = 4 * 1024;         // Memory size in bytes (0xBFC00000 to 0xBFC00FFF -> 4kb)
    localparam logic [31:0] BASE_ADDR = 32'hBFC00000; // Base address of instruction memory
    localparam logic [31:0] TOP_ADDR  = 32'hBFC00FFF; // Top address of instruction memory
    
    // 4 x 1024 bytes memory
    logic [7:0] mem [0:MEM_SIZE-1];                   // Memory array to store instructions, 256 words of 32 bits each

    // Internal signal for address error detection
    logic addr_error;

    // Initialize memory
    initial begin
        $display("LOADING INSTRUCTION MEMORY...");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("program.hex", mem); 
    end
    
    logic [31:0] actual_addr;

    // address error detection logic
    always_comb begin
        addr_error = 1'b0; // default no error
        actual_addr = addr_i + BASE_ADDR;

        // Address alignment and range checking
        if (actual_addr < BASE_ADDR || actual_addr > TOP_ADDR) begin
            addr_error = 1'b1;
            $display("Warning: Address out of range: %h.", addr_i);
        end 
        else if (addr_i[1:0] != 2'b00) begin
            addr_error = 1'b1;
            $display("Warning: Unaligned address detected: %h.", addr_i);
        end
    end

    // Read logic: fetch instruction
    // combine 4 bytes to form a 32-bit instruction
    always_comb begin
        if (addr_error) begin
            // Return error value if address is invalid
            instr_o = 32'hDEADBEEF; 
        end 
        else begin
            // convert physical address to memory offset
            logic [11:0] local_addr = actual_addr[11:0];
            instr_o = {mem[local_addr+3], mem[local_addr+2], mem[local_addr+1], mem[local_addr]};
        end
    end 
endmodule
