module main_decoder (
    input logic [6:0] opcode,    // Opcode from instruction
    output logic reg_wr_en,       // Register Write Enable
    output logic mem_wr_en,       // Memory Write Enable
    output logic [1:0] imm_src,   // Immediate source control
    output logic alu_src,         // ALU source (register or immediate)
    output logic branch,         // Branch control
    output logic result_src,      // Result source (ALU or memory)
    output logic [1:0] alu_op     // ALU Operation control
);

    always_comb begin
        // opcode decoding
        case (opcode)
            // L-type op = 3
            7'b0000011: begin
                reg_wr_en = 1;
                mem_wr_en = 0;
                imm_src = 2'b00;
                alu_src = 1;
                result_src = 1;
                alu_op = 2'b00;
            end

            // S-type, op = 35
            7'b0100011: begin
                reg_wr_en = 0;
                mem_wr_en = 1;
                imm_src = 2'b01;
                alu_src = 1;
                alu_op = 2'b00;
            end

            // R-type, op = 51
            7'b0110011: begin
                reg_wr_en = 1;
                mem_wr_en = 0;
                alu_src = 0;
                alu_op = 2'b10;
            end

            // B-type, op = 99
            7'b1100011: begin
                reg_wr_en = 0;
                mem_wr_en = 0;
                imm_src = 2'b10;
                alu_src = 0;
                branch = 1;
                alu_op = 2'b01;
            end
            default: begin
                reg_wr_en = 0;
                mem_wr_en = 0;
                imm_src = 2'b00;
                alu_src = 0;
                branch = 0;
                result_src = 0;
                alu_op = 2'b00; 
            end
        endcase      
    end
endmodule
