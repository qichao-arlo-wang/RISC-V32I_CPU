module alu (
    input logic [31:0] src_a_i, src_b_i,
    input logic [2:0] alu_control_i,
    output logic [31:0] alu_result_o,
    output logic zero_o
);
    // ALU operation logic
    always_comb begin
        case (alu_control_i)
            3'b0000: alu_result_o = src_a_i + src_b_i;    // ADD
            3'b0001: alu_result_o = src_a_i - src_b_i;    // SUB
            3'b0101: alu_result_o = src_a_i << src_b_i[4:0];   // SLL
            3'b0111: alu_result_o = ($signed(src_a_i) < $signed(src_b_i))? 32'd1 : 32'd0; // SLT
            3'b1000: alu_result_o = (src_a_i < src_b_i)? 32'd1 : 32'd0; // SLTU
            3'b0110: alu_result_o = src_a_i >> src_b_i[4:0];  // SRL
            3'b1001: alu_result_o = $signed(src_a_i) >>> src_b_i[4:0]; // SRA
            3'b0011: alu_result_o = src_a_i | src_b_i;    // OR
            3'b0100: alu_result_o = src_a_i ^ src_b_i;    // XOR
            3'b0010: alu_result_o = src_a_i & src_b_i;    // AND
            default: alu_result_o = 32'd0;    // default 0
        endcase 
        // set the zero flag based on alu result
        zero_o = (alu_result_o == 32'd0);
    end
endmodule
