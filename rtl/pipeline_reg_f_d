module pipeline_reg_f_d #(
    parameter WIDTH = 32
)(
    input logic clk_i,
    input logic stall_i,
    input logic flush_i,

    input logic [WIDTH - 1:0] instr_f_i, // fetch stage instruction
    input logic [WIDTH - 1:0] pc_f_i,
    input logic [WIDTH - 1:0] pc_plus_4_f_i, 
    
    output logic [WIDTH - 1:0] instr_d_o,
    output logic [WIDTH - 1:0] pc_d_o,
    output logic [WIDTH - 1:0] pc_plus_4_d_o

);
    always_ff @(posedge clk_i) begin
        if (!stall_i) begin
            instr_d_o <= instr_f_i;
            pc_d_o <= pc_f_i;
            pc_plus_4_d_o <= pc_plus_4_f_i;
        end
        if (flush_i) begin
            instr_d_o <= 0;     
        end 


    end

endmodule
