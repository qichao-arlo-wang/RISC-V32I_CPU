module Main_Decoder (
    input logic [6:0] opcode,    // Opcode from instruction
    output logic RegWrite,       // Register Write Enable
    output logic MemWrite,       // Memory Write Enable
    output logic [1:0] ImmSrc,   // Immediate source control
    output logic ALUsrc,         // ALU source (register or immediate)
    output logic Branch,         // Branch control
    output logic ResultSrc,      // Result source (ALU or memory)
    output logic [1:0] ALUOp     // ALU Operation control
);

    always_comb begin
        RegWrite = 0;
        MemWrite = 0;
        ImmSrc = 2'b00;
        ALUsrc = 0;
        Branch = 0;
        ResultSrc = 0;
        ALUOp = 2'b00;

        case (opcode)
            /*7'b0000011: begin // Load (lw)
                RegWrite = 1;
                MemWrite = 0;
                ImmSrc = 2'b00;
                ALUsrc = 1;
                ResultSrc = 1;
                ALUOp = 2'b00;
            end

            7'b0100011: begin // Store (sw)
                RegWrite = 0;
                MemWrite = 1;
                ImmSrc = 2'b01;
                ALUsrc = 1;
                ALUOp = 2'b00;
            end */
            7'b0110011: begin // R-type
                RegWrite = 1;
                MemWrite = 0;
                ALUsrc = 0;
                ALUOp = 2'b10;
            end
            7'b1100011: begin // Branch (beq)
                RegWrite = 0;
                MemWrite = 0;
                ImmSrc = 2'b10;
                ALUsrc = 0;
                Branch = 1;
                ALUOp = 2'b01;
            end
            default: begin
                RegWrite = 0;
                MemWrite = 0;
            end
        endcase
    end
endmodule
