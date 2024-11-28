module alu (
    input  logic [31:0] src_a_i, src_b_i,
    input  logic [3:0]  alu_control_i,
    output logic [31:0] alu_result_o,
    output logic        zero_o
);
    // ALU operation logic
    always_comb begin
        case (alu_control_i)
            4'h0: alu_result_o = src_a_i + src_b_i;                                     // ADD 
            4'h1: alu_result_o = src_a_i - src_b_i;                                     // SUB
            4'h2: alu_result_o = src_a_i << src_b_i[4:0];                               // SLL (shift left logical)
            4'h3: alu_result_o = ($signed(src_a_i) < $signed(src_b_i)) ? 32'd1 : 32'd0; // SLT (set less than)
            4'h4: alu_result_o = (src_a_i < src_b_i) ? 32'd1 : 32'd0;                   // SLTU (set less than unsigned)
            4'h5: alu_result_o = src_a_i >> src_b_i[4:0];                               // SRL (shift right logical)
            4'h6: alu_result_o = $signed(src_a_i) >>> src_b_i[4:0];                     // SRA (shift right arithmetic)
            4'h7: alu_result_o = src_a_i | src_b_i;                                     // OR
            4'h8: alu_result_o = src_a_i ^ src_b_i;                                     // XOR
            4'h9: alu_result_o = src_a_i & src_b_i;                                     // AND
            default: alu_result_o = 32'd0;                                                 // default 0
        endcase

        // Set zero_o based on ALU result
        zero_o = (alu_result_o == 32'd0) ? 1'b1 : 1'b0; 
    end
endmodule
