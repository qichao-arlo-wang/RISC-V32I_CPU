module alu (
    input logic [31:0] src_a, src_b,
    input logic [3:0] alu_control,
    output logic [31:0] alu_result,
    output logic zero
);
    // ALU operation logic
    always_comb begin
        case (alu_control)
            4'b0000: alu_result = src_a + src_b;    // addition
            4'b0001: alu_result = src_a - src_b;    // subtraction
            4'b0010: alu_result = src_a & src_b;    // bitwise AND
            4'b0011: alu_result = src_a | src_b;    // bitwise OR
            4'b0100: alu_result = src_a ^ src_b;    // bitwise XOR
            4'b0101: alu_result = src_a << src_b[4:0];  // logic left shift by the value in src_b[4:0]
            4'b0110: alu_result = src_a >> src_b[4:0];  // logic right shift by the value in src_b[4:0]
            default: alu_result = 0;    // set default alu_result to 0
        endcase 
        // set the zero flag
        eq = (src_a == src_b);
    end
endmodule
