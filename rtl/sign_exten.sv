module sign_exten (
    input logic [24:0] instr_31_7, //  bits from 31 to 7
    input logic [2:0] imm_src,             
    output logic [31:0] imm_ext             
);

    
    always_comb begin
        case (imm_src)  // Use imm_src to determine the type of extension
            2'b000:       // I-type 
                imm_ext = {{20{instr_31_7[24]}}, instr_31_7[24:13]};  // Bits 31:20 of original instruction is now 24:13

            2'b001:       // S-type
                imm_ext = {{20{instr_31_7[24]}}, instr_31_7[24:18], instr_31_7[4:0]};  // Bits 31:25 and 11:7 of original instruction

            2'b010:       // B-type
                imm_ext = {{20{instr_31_7[24]}}, instr_31_7[0], instr_31_7[23:18], instr_31_7[4:1], 1'b0};  // Form branch offset
            
            2'b011:       // U-type 
                imm_ext = {instr_31_7[24:5], 12{1'b0}};  // Bits 31:12 of imm + 12 bit 0 for U type instruction

            2'b100:       // J-type 
                imm_ext = {{12{instr_31_7[24]}}, instr_31_7[12:5], instr_31_7[13], instr_31_7[23:14], 1'b0};

            2'b101:       // slli, srri, srai
                imm_ext = {27{1'b0}, instr_31_7[17:13]};

            default:     // Default 
                imm_ext = 32'd0;  // Output zero 
        endcase
    end
endmodule
