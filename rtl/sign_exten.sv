
module sign_exten (
    input logic [24:0] partial_instruction, //  bits from 31 to 7
    input logic [1:0] imm_src,             
    output logic [31:0] imm_op             
);

    
    always_comb begin
        case (imm_src)  // Use imm_src to determine the type of extension
            2'b00:       // I-type 
                imm_op = {{20{partial_instruction[24]}}, partial_instruction[24:13]};  // Bits 31:20 of original instruction is now 24:13

            2'b01:       // S-type
                imm_op = {{20{partial_instruction[24]}}, partial_instruction[24:18], partial_instruction[4:0]};  // Bits 31:25 and 11:7 of original instruction

            2'b10:       // B-type
                imm_op = {{19{partial_instruction[24]}}, partial_instruction[24], partial_instruction[0], partial_instruction[23:18], partial_instruction[4:1], 1'b0};  // Form branch offset

            default:     // Default 
                imm_op = 32'd0;  // Output zero 
        endcase
    end
endmodule

