module PC_Reg (
    input  logic        clk,        // Clock
    input  logic        rst,        // Reset
    input  logic [31:0] next_PC,    // Next PC value
    output logic [31:0] PC          // Current PC value
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= 32'b0;            // Reset PC to 0
        end
        else begin
            PC <= next_PC;          // Update PC with next_PC
        end
    end

endmodule
