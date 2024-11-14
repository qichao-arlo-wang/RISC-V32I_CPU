module top (
    input logic clk,
    input logic rst,
    output logic [31:0] a0 // Register a0 output
);


    // Instruction & fields
    logic [31:0] instruction;
    logic [6:0] opcode = instruction[6:0];
    logic [2:0] funct3 = instruction[14:12];
    logic funct7_5 = instruction[30];

    // Control signals
    logic RegWrite, MemWrite, ALUsrc, Branch, ResultSrc;
    logic [1:0] ImmSrc;
    logic [2:0] ALUControl;
    logic Zero;

    // Immediate
    logic [31:0] immediate;

    // Register data 
    logic [31:0] reg_data1, reg_data2, alu_in2, alu_out;

    // Instantiate Instruction Memory
    Instruction_Memory imem (
        .addr(pc),
        .instruction(instruction)
    );

    // Instantiate Control Unit
    Control_Unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .Zero(Zero),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ImmSrc(ImmSrc),
        .ALUsrc(ALUsrc),
        .Branch(Branch),
        .ResultSrc(ResultSrc),
        .ALUControl(ALUControl),
        .PCsrc(PCsrc)
    );

    // Instantiate Sign-Extension Unit
    Sign_Extension_Unit sext (
        .instruction(instruction),
        .ImmSrc(ImmSrc),
        .immediate(immediate)
    );

    // Output a0 register content
    assign a0 = reg_data1; // Register a0 mapped to reg_data1

/*
    // PC update logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

    assign next_pc = (PCsrc) ? pc + (immediate << 1) : pc + 4;
*/
endmodule

