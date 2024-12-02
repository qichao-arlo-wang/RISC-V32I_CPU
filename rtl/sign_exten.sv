module sign_exten (
    input logic [24:0] instr_31_7_i,  // instruction[31:7]
    input logic [2:0]  imm_src_i,
    input logic signed_i,

    output logic [31:0] imm_ext_o
);

    always_comb begin
        case (imm_src_i)  // Use imm_src to determine the type of extension
            3'b000:       
                // I-type 
                // imm = instruction[31:20] = instr_31_7_i[24:13]
                // sign extension from 12 bit to 32 bit
                case (signed_i)
                    1'b1: imm_ext_o = {{20{instr_31_7_i[24]}}, instr_31_7_i[24:13]};
                    1'b0: imm_ext_o = {{20{1'b0}}, instr_31_7_i[24:13]};

            3'b001:       
                // S-type
                // imm = instruction[31:25] + instruction[11:7] = instr_31_7_i[24:18] + instr_31_7_i[4:0]
                // sign extension from 12 bit to 32 bit
                imm_ext_o = {{20{instr_31_7_i[24]}}, instr_31_7_i[24:18], instr_31_7_i[4:0]};

            3'b010:       
                // B-type
                // imm = instruction[31] + instruction[7] + instruction[30:25] + instruction[11:8]
                //     = instr_31_7_i[24] + instr_31_7_i[0] + instr_31_7_i[23:18] + instr_31_7_i[4:1]
                // sign extension from 12 bit to 32 bit
                imm_ext_o = {{19{instr_31_7_i[24]}}, instr_31_7_i[24], instr_31_7_i[0], instr_31_7_i[23:18], instr_31_7_i[4:1], 1'b0};
            
            3'b011:       
                // U-type
                // imm = instruction[31:12] = instr_31_7_i[24:5]
                // lower 12 bits are extended with zeros
                imm_ext_o = {instr_31_7_i[24:5], 12'b0};  
            
            3'b100:       
                // J-type
                // imm = instruction[31] + instruction[19:12] + instruction[20] + instruction[30:21]
                //     = instr_31_7_i[24] + instr_31_7_i[11:4] + instr_31_7_i[12] + instr_31_7_i[23:14]
                imm_ext_o = {{12{instr_31_7_i[24]}}, instr_31_7_i[12:5], instr_31_7_i[13], instr_31_7_i[23:14], 1'b0};

            3'b101:
                case (signed_i)
                    1'b0: imm_ext_o = {{27{1'b0}}, instr_31_7_i[17:13]};            // SLLI, SRRI
                    1'b1: imm_ext_o = {{27{instr_31_7_i[17]}}, instr_31_7_i[17:13]}; // SRAI
                endcase

            3'b111:
                //unsigned
                imm_ext_o = {{19{1'b0}}, instr_31_7_i[24], instr_31_7_i[0], instr_31_7_i[23:18], instr_31_7_i[4:1], 1'b0};
                
            default:     // Default 
                imm_ext_o = 32'd0;  // Output zero 
        endcase
    end
endmodule
