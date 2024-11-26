module alu_decoder (
    input logic [1:0] alu_op_i,          // ALU Operation code from Main Decoder
    input logic [2:0] funct3_i,         // funct3 field from instruction
    input logic funct7_5_i,             // Bit 5 of funct7 field
    output logic [3:0] alu_control_o     // ALU Control signal
);

    always_comb begin
        case (alu_op_i)
            2'b00: alu_control_o = 4'b000; // Add for lw/sw
            2'b01: alu_control_o = 4'b001; // Subtract for branch
            2'b10: begin // I&R-type operations
                case ({funct3_i, funct7_5_i})
                    4'b0000: alu_control_o = 4'b0000; // ADD
                    4'b0001: alu_control_o = 4'b0001; // SUB
                    4'b0010: alu_control_o = 4'b0101; // SLL
                    4'b0100: alu_control_o = 4'b0101; // SLT *need to modify with ALU
                    4'b0110: alu_control_o = 4'b0101; // SLT(U) *need to modify with ALU
                    4'b1010: alu_control_o = 4'b0110; // SRL
                    4'b1011: alu_control_o = 4'b0101; // SRA
                    4'b1100: alu_control_o = 4'b0011; // OR
                    4'b1000: alu_control_o = 4'b0100; // XOR
                    4'b1110: alu_control_o = 4'b0010; // AND
                    default: alu_control_o = 4'b0000; // Default ADD
                endcase
            end
            default: alu_control_o = 4'b000; // Default ADD
        endcase
    end
endmodule
