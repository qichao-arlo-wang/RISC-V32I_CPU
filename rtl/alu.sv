module alu (
    input logic [31:0] src_a_i, src_b_i,
    input logic [3:0] alu_control_i,
    output logic [31:0] alu_result_o,
    output logic zero_o
);
    // ALU operation logic
    always_comb begin
        case (alu_control_i)
            4'b0000: alu_result_o = src_a_i + src_b_i;                                     // ADD 
            4'b0001: alu_result_o = src_a_i - src_b_i;                                     // SUB & BNE
            4'b0101: alu_result_o = src_a_i << src_b_i[4:0];                               // SLL (shift left logical)
            4'b0111: alu_result_o = ($signed(src_a_i) < $signed(src_b_i)) ? 32'd1 : 32'd0; // SLT (set less than)
            4'b1000: alu_result_o = (src_a_i < src_b_i) ? 32'd1 : 32'd0;                   // SLTU (set less than unsigned)
            4'b0110: alu_result_o = src_a_i >> src_b_i[4:0];                               // SRL (shift right logical)
            4'b1000: alu_result_o = $signed(src_a_i) >>> src_b_i[4:0];                     // SRA (shift right arithmetic)
            4'b0011: alu_result_o = src_a_i | src_b_i;                                     // OR
            4'b0100: alu_result_o = src_a_i ^ src_b_i;                                     // XOR
            4'b0010: alu_result_o = src_a_i & src_b_i;                                     // AND

            4'b1010: alu_result_o = src_a_i - src_b_i;                                     // SUB for BNE
            4'b1011: alu_result_o = ($signed(src_a_i) < $signed(src_b_i)) ? 32'd1 : 32'd0; // SLT for BGE

            default: alu_result_o = 32'd0;    // default 0
        endcase
        // Set zero_o based on the ALU control signal and ALU result
        // If alu_control_i is 1010(BNE) or 1011(BGE), zero_o is set to the negation of whether alu_result_o is zero
        // Otherwise, zero_o is set to whether alu_result_o is zero
        zero_o = (alu_control_i == 4'b1010 || alu_control_i == 4'b1011) ? ~(alu_result_o == 32'd0) : (alu_result_o == 32'd0);
    end
endmodule
