module instr_mem (
    input logic [31:0] addr,          // Address (Program Counter)
    output logic [31:0] instr   // Fetched instruction
);

    parameter int MEM_SIZE = 256; // Memory size
    logic [7:0] mem [0:MEM_SIZE*4-1]; // Memory array to store instructions, 256 words of 32 bits each

    // Initialize memory
    initial begin
        $display("Loading rom.");
        
        // the defalut path when running the simulation is the tests directory
        // Read memory file with byte-level storage
        $readmemh("instr_mem_test.hex", mem); 
    end

    //Combine 4 bytes to form a 32-bit instruction
always_comb begin
    // Address alignment and range checking
    if (addr[1:0] != 2'b00) begin
        $display("Warning: Unaligned address detected: %h. Returning default NOP instruction.", addr);
        instr = 32'h00000013; // Return default NOP instruction
    end else begin
        //Combine 4 bytes to form a 32-bit instruction
        if ((addr >> 2) < MEM_SIZE) begin
            instr = {mem[addr], mem[addr + 1], mem[addr + 2], mem[addr + 3]};
        end else begin
            instr = 32'h00000013; // Default NOP instruction
        end
    end
end

endmodule
