module instr_mem (
    input logic [31:0] addr_i,          // Address (Program Counter)
    output logic [31:0] instr_o   // Fetched instruction
);

    localparam int MEM_SIZE = 256; // Memory size
    logic [7:0] mem [0:MEM_SIZE*4-1]; // Memory array to store instructions, 256 words of 32 bits each
    // Internal signal for address error detection
    logic addr_error = 1'b0; // default no error

    // Initialize memory
    initial begin
        $display("Loading rom.");
        
        // the default path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("instr_mem_test.hex", mem); 
    end


    // Combine 4 bytes to form a 32-bit instruction
    always_comb begin
        // Address alignment and range checking
        if (addr_i[1:0] != 2'b00) begin
            addr_error = 1'b1;
            $display("Warning: Unaligned address detected: %h.", addr_i);
        end 
        else if (addr_i > MEM_SIZE - 3) begin
            addr_error = 1'b1;
            $display("Warning: address not in the value range: %h.", addr_i);
        end
    end

    // Read logic 
    // combine 4 bytes to form a 32-bit instruction
    always_comb begin
        if (addr_error) begin
            instr_o = 32'hDEADBEEF; // Return error value if address is invalid
        end 
        else begin
            instr_o = {mem[addr_i], mem[addr_i+1], mem[addr_i+2], mem[addr_i+3]};
        end
    end 
endmodule
