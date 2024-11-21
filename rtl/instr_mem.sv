module instr_mem (
    input logic [31:0] addr,          // Address (Program Counter)
    output logic [31:0] instr   // Fetched instruction
);

    // Memory array 
    logic [31:0] mem [0:255];

    // Initialize mem
    initial begin
        $readmemh("instructions.hex", mem); 
    end

    // Fetch instr
    assign instr = mem[addr >> 2]; 
endmodule
