module main_decoder (
    input logic [6:0] opcode,    // Opcode from 
    input logic [2:0] funct_3,
    output logic reg_wr_en,      // Register Write Enable
    output logic mem_wr_en,      // Memory Write Enable
    output logic [2:0] imm_src,  // Immediate source control
    output logic alu_src,        // ALU source (register or immediate)
    output logic branch,         // Branch control
    output logic result_src,     // Result source (ALU or memory)
    output logic [1:0] alu_op    // ALU Operation control
);

    always_comb begin
        // Opcode decoding
        case (opcode)
            // I-type op = 3 
            // Load instructions
            7'b0000011: begin
                reg_wr_en = 1;
                mem_wr_en = 0;
                imm_src = 3'b000;
                alu_src = 1;
                result_src = 1;
                alu_op = 2'b00;
            end

            // I-type op = 3 
            // Arithmetic Instruction with immediate 
            7'b0010011: begin
                reg_wr_en = 1;
                mem_wr_en = 0;
                alu_src = 1;
                alu_op = 2'b10;

                case (funct_3)
                    // SLLI
                    3'b001: imm_src = 3'b101;
                    // SRLI/SRAI
                    3'b101: imm_src = 3'b101;
                    default: imm_src = 3'b000;
                endcase
            end

            // S-type, op = 35
            // Store instructions
            7'b0100011: begin
                reg_wr_en = 0;
                mem_wr_en = 1;
                imm_src = 3'b001;
                alu_src = 1;
                alu_op = 2'b00;
            end

            // R-type, op = 51
            // Arithmetic instructions
            7'b0110011: begin
                reg_wr_en = 1;
                mem_wr_en = 0;
                alu_src = 0;
                alu_op = 2'b10;
            end

            // B-type, op = 99
            // Branch instructions
            7'b1100011: begin
                reg_wr_en = 0;
                mem_wr_en = 0;
                imm_src = 3'b010;
                alu_src = 0;
                branch = 1;
                alu_op = 2'b01;
            end

            // J-type, op = 111
            // JAL instruction
            7'b1101111: begin
                branch = 1;
                imm_src = 3'b100;
                alu_src = 1;
                reg_wr_en = 1;
                result_src = 1;
            end

            // J-type op = 103
            // JALR instruction
            7'b1100111: begin
                branch = 1;
                imm_src = 3'b100;
                alu_src = 1;
                reg_wr_en = 1;
                result_src = 1;
            end

            // U type op = 55
            // LUI instruction
            7'b0110111: begin
                alu_src = 1;
                reg_wr_en = 1;
                alu_op = 2'b11; // Only use src_b_i in the ALU
            end

            // U type op = 23
            // AUIPC instruction
            7'b0010111: begin
                alu_src = 1;
                reg_wr_en = 1;
                alu_op = 2'b11; // Only use src_b_i in the ALU
            end

            default: begin
                reg_wr_en = 0;
                mem_wr_en = 0;
                imm_src = 3'b000;
                alu_src = 0;
                branch = 0;
                result_src = 0;
                alu_op = 2'b00;
            end
        endcase
    end
endmodule
