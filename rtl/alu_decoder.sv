module alu_decoder (
    input logic [1:0] alu_op_i,          // ALU Operation code from Main Decoder
    input logic [2:0] funct3_i,         // funct3 field from instruction
    input logic funct7_5_i,             // Bit 5 of funct7 field
    output logic [3:0] alu_control_o     // ALU Control signal
);

    always_comb begin
        case (alu_op_i)
            2'b00: alu_control_o = 4'b000; // Add for lw/sw
            2'b01: begin // branch
                case (funct3_i)
                    3'b000: alu_control_o = 4'b0001; // BEQ SUB
                    3'b001: alu_control_o = 4'b0001; // BNE SUB
                    3'b100: alu_control_o = 4'b0111; // BLT SLT 
                    3'b101: alu_control_o = 4'b0111; // BGE SLT 
                    3'b110: alu_control_o = 4'b1000; // BLT SLTU 
                    3'b111: alu_control_o = 4'b1000; // BGE SLTU 
                    default: alu_control_o = 4'b0001; // Default Sub
                endcase
            end
            2'b10: begin // I&R-type operations
                case ({funct3_i, funct7_5_i})
                    4'b0000: alu_control_o = 4'b0000; // ADD
                    4'b0001: alu_control_o = 4'b0001; // SUB
                    4'b0010: alu_control_o = 4'b0101; // SLL
                    4'b0100: alu_control_o = 4'b0111; // SLT 
                    4'b0110: alu_control_o = 4'b1000; // SLT(U)
                    4'b1010: alu_control_o = 4'b0110; // SRL
                    4'b1011: alu_control_o = 4'b1001; // SRA
                    4'b1100: alu_control_o = 4'b0011; // OR
                    4'b1000: alu_control_o = 4'b0100; // XOR
                    4'b1110: alu_control_o = 4'b0010; // AND
                    default: alu_control_o = 4'b0000; // Default ADD
                endcase
            end
            2'b11: alu_control_o = 4'b1111; // U type output alu with src_b_i<<12
            default: alu_control_o = 4'b0000; // Default ADD
        endcase
    end
endmodule
