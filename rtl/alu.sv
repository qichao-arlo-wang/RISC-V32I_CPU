module alu (
    input logic [31:0] alu_op1, alu_op2,
    input logic [3:0] alu_ctrl,
    output logic [31:0] alu_out,
    output logic eq 
);
    // ALU operation logic
    always_comb begin
        case (alu_ctrl)
            4'b0000: alu_out = alu_op1 + alu_op2;    // addition
            4'b0001: alu_out = alu_op1 - alu_op2;    // subtraction
            4'b0010: alu_out = alu_op1 & alu_op2;    // bitwise AND
            4'b0011: alu_out = alu_op1 | alu_op2;    // bitwise OR
            4'b0100: alu_out = alu_op1 ^ alu_op2;    // bitwise XOR
            4'b0101: alu_out = alu_op1 << alu_op2[4:0];  // logic left shift by the value in alu_op2[4:0]
            4'b0110: alu_out = alu_op1 >> alu_op2[4:0];  // logic right shift by the value in alu_op2[4:0]
            default: alu_out = 0;    // set default alu_out to 0
        endcase 
        // set the zero flag
        eq = (alu_op1 == alu_op2);
    end
endmodule
