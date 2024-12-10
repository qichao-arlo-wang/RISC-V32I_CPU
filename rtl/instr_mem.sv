module instr_mem (
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,   // Address (Program Counter)
    /* verilator lint_on UNUSED */
    output logic [31:0] instr_o   // Fetched instruction
);

    localparam        MEM_SIZE  = 4 * 1024;             // Memory size in bytes (0xBFC00000 to 0xBFC00FFF -> 4KB)
    // localparam [31:0] BASE_ADDR = 32'hBFC00000;         // Base address of instruction memory
    // localparam [31:0] TOP_ADDR  = BASE_ADDR + MEM_SIZE -1;         // Top address of instruction memory
    localparam string MEM_FILE  = "program.hex";  // default path
    // localparam string MEM_FILE  = "/root/Documents/Group-9-RISC-V/tb/test_out/1_addi_bne/program.hex"; // Zitong's path

    // 4 x 1024 bytes memory
    logic [7:0] mem [0:MEM_SIZE-1];

    // Internal signal for address error detection
    // logic addr_error;

    // Initialize memory
    initial begin
        $display("LOADING INSTRUCTION MEMORY...");
        
        // The default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh(MEM_FILE, mem); 
    end

    // Read logic: fetch instruction
    always_comb begin
        // instr_o = 32'hDEADBEEF; // Default value
        // if (addr_error) begin
        //     // Return error value if address is invalid
        //     instr_o = 32'hDEADBEEF;
        // end 
        // else begin
            instr_o = {mem[addr_i[11:0] + 3], mem[addr_i[11:0] + 2], mem[addr_i[11:0] + 1], mem[addr_i[11:0]]};
        // end
    end

    // // Address error detection logic
    // always_comb begin
    //     addr_error = 1'b0; // Default: no error
    //     // range checking
    //     if (addr_i < BASE_ADDR || addr_i > TOP_ADDR) begin
    //         addr_error = 1'b1;
    //         $display("Warning: Address out of range: %h.", addr_i);
    //     end 
    //     // check alignment
    //     else if (addr_i[1:0] != 2'b00) begin
    //         addr_error = 1'b1;
    //         $display("Warning: Unaligned address detected: %h.", addr_i);
    //     end
    //     if (addr_error) begin
    //         instr_o = 32'hDEADBEEF;
    //     end else begin
    //         // valid access
    //         instr_o = {mem[addr_i[11:0]+3], mem[addr_i[11:0]+2], mem[addr_i[11:0]+1], mem[addr_i[11:0]]};
    //     end
    // end
endmodule
