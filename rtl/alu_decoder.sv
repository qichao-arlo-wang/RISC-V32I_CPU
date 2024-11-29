module alu_decoder (
    input logic [1:0] alu_op_i,         // ALU Operation code from Main Decoder
    input logic [2:0] funct3_i,         // funct3 field from instruction
    input logic [6:0] funct7_i,             // funct7 field from instruction

    output logic [3:0] alu_control_o    // ALU Control signal
);

    always_comb begin
        case (alu_op_i)
            2'b0: begin // I-type operations
                case (funct3_i)
                    3'h0: alu_control_o = 4'h0; // ADD
                    3'h4: alu_control_o = 4'h8; // XOR
                    3'h6: alu_control_o = 4'h7; // OR
                    3'h7: alu_control_o = 4'h9; // AND 
                    3'h1: begin
                        case (funct7_i)
                            7'b0: alu_control_o = 4'h2; // SLLI
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h5: begin
                        case (funct7_i)
                            7'b0:  alu_control_o = 4'h5; // SRLI
                            7'h20: alu_control_o = 4'h6; // SRAI
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h2: alu_control_o = 4'h3; // SLTI
                    3'h3: alu_control_o = 4'h4; // SLTIU
                    default: alu_control_o = 4'hA; // Default 32'b0
                endcase
            end

            2'b01: begin // B-type operations
                alu_control_o = 4'h1;
            end

            2'b10: begin // R-type operations
                case (funct3_i)
                    3'h0: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h0;    // ADD
                            7'h20: alu_control_o = 4'h1;  // SUB
                            default: $display ("Error: invalid instruction");
                        endcase 
                    end
                    3'h4: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h8;   // XOR
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h6: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h7;   // OR
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h7: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h9;   // AND
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h1: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h2;   // SLL
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h5: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h5;   // SRL
                            7'h20: alu_control_o = 4'h6;  // SRA
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h2: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h3;   // SLT
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    3'h3: begin
                        case (funct7_i)
                            7'h0: alu_control_o = 4'h4;  //SLTU
                            default: $display ("Error: invalid instruction");
                        endcase
                    end
                    default: alu_control_o = 4'hA; // Default 0
                endcase
            end

            // S-TYPE instruction
            2'b11: alu_control_o = 4'h0; // Default ADD

            default: alu_control_o = 4'h0; // Default ADD
        endcase
    end
endmodule
