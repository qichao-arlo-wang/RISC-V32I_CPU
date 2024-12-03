module pc_reg (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] pc_next_i,    // Next pc value

    output logic [31:0] pc_o          // Current pc value
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin  
            pc_o <= 32'h0;
        end
        else begin
            pc_o <= pc_next_i;
        end
    end

endmodule
