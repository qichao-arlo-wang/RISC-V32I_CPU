module clocked_register (
    input  logic         clk,
    input  logic [31:0]  pc_next,
    output logic [31:0]  pc
);

    always_ff @(posedge clk) begin
        pc <= pc_next;
    end

endmodule