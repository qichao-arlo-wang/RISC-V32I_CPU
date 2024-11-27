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
            end
            4'b0001: begin 
                alu_result = src_a - src_b;    // SUB or BNE (handled externally)
            end
            4'b0101: begin
                alu_result = src_a << src_b[4:0];   // SLL
            end
            4'b0111: begin
                alu_result = ($signed(src_a) < $signed(src_b)) ? 32'd1 : 32'd0; // SLT
            end
            4'b1000: begin
                alu_result = (src_a < src_b) ? 32'd1 : 32'd0; // SLTU
            end
            4'b0110: begin
                alu_result = src_a >> src_b[4:0];  // SRL
            end
            4'b1001: begin
                alu_result = $signed(src_a) >>> src_b[4:0]; // SRA
            end
            4'b0011: begin
                alu_result = src_a | src_b;    // OR
            end
            4'b0100: begin
                alu_result = src_a ^ src_b;    // XOR
            end
            4'b0010: begin
                alu_result = src_a & src_b;    // AND
            end
            default: begin
                alu_result = 32'd0;    // Default result is 0
            end
        endcase 
        // Set zero flag: 1 if alu_result is 0, 0 otherwise
        zero = (alu_result == 32'd0) ? 1'b1 : 1'b0;
    end
endmodule
