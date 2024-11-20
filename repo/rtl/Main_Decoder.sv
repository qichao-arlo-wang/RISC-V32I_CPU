module main_decoder (
    input logic [6:0] opcode,    // Opcode from instruction
    output logic reg_write,       // Register Write Enable
    output logic mem_write,       // Memory Write Enable
    output logic [1:0] imm_src,   // Immediate source control
    output logic alu_src,         // ALU source (register or immediate)
    output logic branch,         // Branch control
    output logic result_src,      // Result source (ALU or memory)
    output logic [1:0] alu_op     // ALU Operation control
);

    always_comb begin
        reg_write = 0;
        mem_write = 0;
        imm_src = 2'b00;
        alu_src = 0;
        branch = 0;
        result_src = 0;
        alu_op = 2'b00;

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
                reg_write = 1;
                mem_write = 0;
                alu_src = 0;
                alu_op = 2'b10;
            end
            7'b1100011: begin // Branch (beq)
                reg_write = 0;
                mem_write = 0;
                imm_src = 2'b10;
                alu_src = 0;
                branch = 1;
                alu_op = 2'b01;
            end
            default: begin
                reg_write = 0;
                mem_write = 0;
            end
        endcase
    end
endmodule
