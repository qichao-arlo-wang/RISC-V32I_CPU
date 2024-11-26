module alu_decoder (
    input logic [1:0] alu_op,          // ALU Operation code from Main Decoder
    input logic [2:0] funct3,         // funct3 field from instruction
    input logic funct7_5,             // Bit 5 of funct7 field
    output logic [2:0] alu_control     // ALU Control signal
);

    always_comb begin
        case (alu_op)
            2'b00: alu_control = 3'b000; // Add for lw/sw
            2'b01: alu_control = 3'b001; // Subtract for branch
            2'b10: begin // I&R-type operations
                case ({funct3, funct7_5})
                    4'b0000: alu_control = 3'b000; // ADD
                    4'b0001: alu_control = 3'b001; // SUB
                    4'b0010: alu_control = 3'b101; // SLT
                    4'b1010: alu_control = 3'b110; // SRT                    4'b1100: alu_control = 3'b011; // OR
                    4'b1000: alu_control = 3'b100; // XOR
                    4'b1110: alu_control = 3'b010; // AND
                    default: alu_control = 3'b000; // Default ADD
                endcase
            end
            default: alu_control = 3'b000; // Default ADD
        endcase
    end
endmodule
