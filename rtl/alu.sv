module alu (
    input logic [31:0] src_a_i, src_b_i,
    input logic [3:0] alu_control_i,
    output logic [31:0] alu_result_o,
    output logic zero_o
);
    // ALU operation logic
    always_comb begin
        case (alu_control_i)
            4'b0000: begin 
                alu_result_o = src_a_i + src_b_i;    // ADD
                zero_o = (alu_result_o == 32'd0);    // set the zero flag
            end
            4'b0001: begin 
                alu_result_o = src_a_i - src_b_i;    // SUB & BNE
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0101: begin
                alu_result_o = src_a_i << src_b_i[4:0];   // SLL
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0111: begin
                alu_result_o = ($signed(src_a_i) < $signed(src_b_i))? 32'd1 : 32'd0; // SLT
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b1000: begin
                alu_result_o = (src_a_i < src_b_i)? 32'd1 : 32'd0; // SLTU
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0110: begin
                alu_result_o = src_a_i >> src_b_i[4:0];  // SRL
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b1001: begin
                alu_result_o = $signed(src_a_i) >>> src_b_i[4:0]; // SRA
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0011: begin
                alu_result_o = src_a_i | src_b_i;    // OR
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0100: begin
                alu_result_o = src_a_i ^ src_b_i;    // XOR
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            4'b0010: begin
                alu_result_o = src_a_i & src_b_i;    // AND
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            // Block for 
            4'b1010: begin 
                alu_result_o = src_a_i - src_b_i;    // SUB for BNE
                zero_o = (alu_result_o == 32'd0);    // Inverse Zero needed
            end
            4'b1011: begin 
                alu_result_o = ($signed(src_a_i) < $signed(src_b_i))? 32'd1 : 32'd0;    // SLT for BGE
                zero_o = ~(alu_result_o == 32'd0);    // Inverse Zero needed
            end
            default: begin
                alu_result_o = 32'd0;    // default 0
                zero_o = ~(alu_result_o == 32'd0);    // same above
            end
        endcase 
    end
endmodule
