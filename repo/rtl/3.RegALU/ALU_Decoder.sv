module ALU_Decoder (
    input logic [1:0] ALUOp,          // ALU Operation code from Main Decoder
    input logic [2:0] funct3,         // funct3 field from instruction
    input logic funct7_5,             // Bit 5 of funct7 field
    output logic [2:0] ALUControl     // ALU Control signal
);

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // Add for lw/sw
            2'b01: ALUControl = 3'b001; // Subtract for branch
            2'b10: begin // R-type operations
                case ({funct3, funct7_5})
                    4'b0000: ALUControl = 3'b000; // ADD
                    4'b0001: ALUControl = 3'b001; // SUB
                    4'b0100: ALUControl = 3'b101; // SLT
                    4'b1100: ALUControl = 3'b011; // OR
                    4'b1110: ALUControl = 3'b010; // AND
                    default: ALUControl = 3'b000; // Default ADD
                endcase
            end
            default: ALUControl = 3'b000; // Default ADD
        endcase
    end
endmodule
