module pc_reg (
    input  logic        clk,        // Clock
    input  logic        rst,        // Reset
    input  logic [31:0] next_pc,    // Next pc value
    output logic [31:0] pc          // Current pc value
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;            // Reset pc to 0
        end
        else begin
            pc <= next_pc;          // Update pc with next_pc
        end
    end

endmodule
