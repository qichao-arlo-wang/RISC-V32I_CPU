module sign_exten (
    input logic [24:0] instr_31_7, //  bits from 31 to 7
    input logic [1:0] imm_src,             
    output logic [31:0] imm_ext             
);

    
    always_comb begin
        case (imm_src)  // Use imm_src to determine the type of extension
            2'b00:       // I-type 
                imm_ext = {{20{instr_31_7[24]}}, instr_31_7[24:13]};  // Bits 31:20 of original instruction is now 24:13

            2'b01:       // S-type
                imm_ext = {{20{instr_31_7[24]}}, instr_31_7[24:18], instr_31_7[4:0]};  // Bits 31:25 and 11:7 of original instruction

            2'b10:       // B-type
                imm_ext = {{19{instr_31_7[24]}}, instr_31_7[24], instr_31_7[0], instr_31_7[23:18], instr_31_7[4:1], 1'b0};  // Form branch offset
            
            2'b11:       // U-type 
                imm_ext = {instr_31_7[24:5], 12b'0};  // Bits 31:12 of imm + 12 bit 0 for U type instruction
            
            default:     // Default 
                imm_ext = 32'd0;  // Output zero 
        endcase
    end
endmodule
