module Control_Unit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5,
    input logic Zero,
    output logic RegWrite,
    output logic MemWrite,
    output logic [1:0] ImmSrc,
    output logic ALUsrc,
    output logic Branch,
    output logic ResultSrc,
    output logic [2:0] ALUControl,
    output logic PCsrc
);

    logic [1:0] ALUOp;

    // Instantiate Main Decoder
    Main_Decoder main_dec (
        .opcode(opcode),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .ImmSrc(ImmSrc),
        .ALUsrc(ALUsrc),
        .Branch(Branch),
        .ResultSrc(ResultSrc),
        .ALUOp(ALUOp)
    );

    // Instantiate ALU Decoder
    ALU_Decoder alu_dec (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );

    // Branch decision
    assign PCsrc = Branch & Zero;
endmodule
