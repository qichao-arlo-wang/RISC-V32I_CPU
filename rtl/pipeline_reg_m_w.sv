module pipeline_m_w #(
    parameter WIDTH = 32
)(
    input logic clk_i,

    // control unit
    input logic reg_wr_en_m_i,
    input logic result_src_m_i,
    input logic data_mem_or_pc_mem_sel_m_i,

    output logic reg_wr_en_w_o,
    output logic result_src_w_o,
    input logic data_mem_or_pc_mem_sel_w_i,

    // data path
    input logic [WIDTH - 1:0] alu_result_m_i,
    input logic [WIDTH - 1:0] read_data_m_i, // Read_Data_E in lecture
    input logic [4:0] wr_addr_m_i, // writen address, A3 in lecture
    input logic [WIDTH - 1:0] pc_plus_4_m_i,

    output logic [WIDTH - 1:0] alu_result_w_o,
    output logic [WIDTH - 1:0] read_data_w_o,
    output logic [4:0] wr_addr_w_o,
    output logic [WIDTH - 1:0] pc_plus_4_w_o
);

always_ff @(posedge clk_i) begin
    // control unit
    reg_wr_en_w_o <= reg_wr_en_m_i;
    result_src_w_o <= result_src_m_i;
    data_mem_or_pc_mem_sel_w_o <= data_mem_or_pc_mem_sel_m_i;

    // data path
    alu_result_w_o <= alu_result_m_i;
    read_data_w_o <= read_data_m_i;
    wr_addr_w_o <= wr_addr_m_i;
    pc_plus_4_w_o <= pc_plus_4_m_i;
    
end

endmodule