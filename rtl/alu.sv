module alu (
    input logic [31:0] src_a, src_b,
    input logic [3:0] alu_control,
    output logic [31:0] alu_result,
    output logic zero
);
    // ALU operation logic
    always_comb begin
        case (alu_control)
            4'b0000: begin 
                alu_result = src_a + src_b;    // ADD
                zero = (alu_result == 32'd0);    // set the zero flag
            end
            4'b0001: begin 
                alu_result = src_a - src_b;    // SUB & BNE
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0101: begin
                alu_result = src_a << src_b[4:0];   // SLL
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0111: begin
                alu_result = ($signed(src_a) < $signed(src_b))? 32'd1 : 32'd0; // SLT
                zero = (alu_result == 32'd0);    // same above
            end
            4'b1000: begin
                alu_result = (src_a < src_b)? 32'd1 : 32'd0; // SLTU
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0110: begin
                alu_result = src_a >> src_b[4:0];  // SRL
                zero = (alu_result == 32'd0);    // same above
            end
            4'b1001: begin
                alu_result = $signed(src_a) >>> src_b[4:0]; // SRA
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0011: begin
                alu_result = src_a | src_b;    // OR
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0100: begin
                alu_result = src_a ^ src_b;    // XOR
                zero = (alu_result == 32'd0);    // same above
            end
            4'b0010: begin
                alu_result_o = src_a_i & src_b_i;    // AND
                zero_o = (alu_result_o == 32'd0);    // same above
            end
            // Block for 
            4'b1010: begin 
                alu_result = src_a - src_b;    // SUB for BNE
                zero = (alu_result == 32'd0);    // Inverse Zero needed
            end
            4'b1011: begin 
                alu_result = ($signed(src_a) < $signed(src_b))? 32'd1 : 32'd0;    // SLT for BGE
                zero = ~(alu_result == 32'd0);    // Inverse Zero needed
            end
            default: begin
                alu_result = 32'd0;    // default 0
                zero = ~(alu_result == 32'd0);    // same above
            end
        endcase 
    end
endmodule
