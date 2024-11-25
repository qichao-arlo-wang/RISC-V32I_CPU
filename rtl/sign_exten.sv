module sign_exten (
    input logic [24:0] instr_31_7_i, //  bits from 31 to 7
    input logic [2:0] imm_src_i,             
    output logic [31:0] imm_ext_o             
);

    always_comb begin
        case (imm_src_i)  // Use imm_src to determine the type of extension
            3'b000:       // I-type 
                imm_ext_o = {{20{instr_31_7_i[24]}}, instr_31_7_i[24:13]};  // Bits 31:20 of original instruction is now 24:13

            3'b001:       // S-type
                imm_ext_o = {{20{instr_31_7_i[24]}}, instr_31_7_i[24:18], instr_31_7_i[4:0]};  // Bits 31:25 and 11:7 of original instruction

            3'b010:       // B-type
                imm_ext_o = {{19{instr_31_7_i[24]}}, instr_31_7_i[24], instr_31_7_i[0], instr_31_7_i[23:18], instr_31_7_i[4:1], 1'b0};  // Form branch offset
            
            3'b011:       // U-type 
                imm_ext_o = {instr_31_7_i[24:5], 12'b0};  // Bits 31:12 of imm + 12 bit 0 for U type instruction
            
            3'b100:       // J-type 
                imm_ext_o = {{12{instr_31_7_i[24]}}, instr_31_7_i[12:5], instr_31_7_i[13], instr_31_7_i[23:14], 1'b0};

            3'b101:       // slli, srri, srai
                imm_ext_o = {27{1'b0}, instr_31_7_i[17:13]};
            default:     // Default 
                imm_ext_o = 32'd0;  // Output zero 
        endcase
    end
endmodule
