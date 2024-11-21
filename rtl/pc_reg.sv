module pc_reg (
    input  logic        clk,        // Clock
    input  logic [31:0] next_pc,    // Next pc value
    output logic [31:0] pc          // Current pc value
);

    always_ff @(posedge clk) begin
        pc <= pc_next;
    end

endmodule
