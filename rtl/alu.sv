module alu (
    input logic [31:0] src_a, src_b,
    input logic [2:0] alu_control,
    output logic [31:0] alu_result,
    output logic zero
);
    // ALU operation logic
    always_comb begin
        case (alu_control)
            3'b000: alu_result = src_a + src_b;    // ADD
            3'b001: alu_result = src_a - src_b;    // SUB
            3'b010: alu_result = src_a & src_b;    // AND
            3'b011: alu_result = src_a | src_b;    // OR
            3'b100: alu_result = src_a ^ src_b;    // XOR
            3'b101: alu_result = ($signed(src_a) < $signed(src_b))? 32'd1 : 32'd0; //SLT: compares src_a and src_b as signed integers, 1 if true else 0
            3'b110: alu_result = src_a >> src_b[4:0];  // SRL
            3'b111: alu_result = src_a << src_b[4:0]; //SLL
            default: alu_result = 32'd0;    //  default 0
        endcase 
        // set the zero flag based on alu result
        zero = (alu_result == 32'd0);
    end
endmodule
