module pc_reg (
    input  logic        clk,
    input  logic [31:0] pc_next_i,    // Next pc value

    output logic [31:0] pc_o          // Current pc value
);

    always_ff @(posedge clk) begin
        pc_o <= pc_next_i;
    end

endmodule
