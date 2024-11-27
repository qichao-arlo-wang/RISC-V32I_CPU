module instruction_memory (
    input logic [31:0] addr,          // Address (Program Counter)
    output logic [31:0] instruction   // Fetched instruction
);

    // Memory array 
    logic [7:0] mem [0:1023];

    // Initialize mem
    initial begin
        // load big-endian instructions from program.hex
        $readmemh("/root/Documents/Group-9-RISC-V/rtl/program.hex", mem); 
    end

        // //convert each instruction to little-endian
        // for (int i = 0; i < 256; i++) begin
        //     mem[i] = {mem[i][7:0], mem[i][15:8], mem[i][23:16], mem[i][31:24]};
        // end


    // Fetch instruction
    assign instruction = (addr[1:0] == 2'b00 && addr <= 1020) ? {mem[addr + 3], mem[addr + 2], mem[addr + 1], mem[addr]} : 32'b0;
endmodule
