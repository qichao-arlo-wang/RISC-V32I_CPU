module pipeline_reg_f_d #(
    parameter WIDTH = 32
)(
    input logic clk_i,
    input logic flush_i,
    input logic stall_i, // store for load

    // control unit
    // note branch_d & jump_d are in lecture slides
    input logic reg_wr_en_d_i,
    input logic result_src_d_i,
    input logic mem_wr_en_d_i,
    input logic mem_byte_en_d_i,
    input logic pc_src_d_i,
    input logic [3:0] alu_control_d_i,
    input logic alu_src_d_i,
    input logic alu_src_a_d_i,
    input logic [WIDTH-1:0] option_d_i,
    input logic [WIDTH-1:0] option2_d_i,
    input logic data_mem_or_pc_mem_sel_d_i,

    output logic reg_wr_en_e_o,
    output logic result_src_e_i,
    output logic mem_wr_en_e_o,
    output logic mem_byte_en_e_o,
    output logic pc_src_e_o,
    output logic [3:0] alu_control_e_o,
    output logic alu_src_e_o,
    output logic alu_src_a_e_o,
    output logic [WIDTH-1:0] option_e_o,
    output logic [WIDTH-1:0] option2_e_o,
    output logic data_mem_or_pc_mem_sel_e_o,

    // data path
    input logic [WIDTH - 1:0] rd_data1_d_i, // RD1_D in lecture slide
    input logic [WIDTH - 1:0] rd_data2_d_i,
    input logic [WIDTH - 1:0] pc_d_i,
    input logic [4:0] rd_addr1_d_i, // Rs1_D, source register in lecture slide
    input logic [4:0] rd_addr2_d_i,
    input logic [4:0] wr_addr_d_i, // Rd_D in lecture
    input logic [WIDTH - 1:0] imm_ext_d_i,
    input logic [WIDTH - 1:0] pc_plus_4_d_i,

    output logic [WIDTH - 1:0] rd_data1_e_o,
    output logic [WIDTH - 1:0] rd_data2_e_o,
    output logic [WIDTH - 1:0] pc_e_o,
    output logic [4:0] rd_addr1_e_o,
    output logic [4:0] rd_addr2_e_o,
    output logic [4:0] wr_addr_e_o,
    output logic [WIDTH - 1:0] imm_ext_e_o,
    output logic [WIDTH - 1:0] pc_plus_4_e_o

    
);

    always_ff @(posedge clk) begin
        // control unit
        if (!flush_i && !stall_i) begin
            reg_wr_en_e_o <= reg_wr_en_d_i;
            mem_wr_en_e_o <= mem_wr_en_d_i;
            pc_src_e_o <= pc_src_d_i;
        end
        else begin
            reg_wr_en_e_o <= 0;
            mem_wr_en_e_o <= 0;
            pc_src_e_o <= 1'b0;
        end
        
        result_src_d_i <= result_src_d_i;
        mem_byte_en_e_o <= mem_byte_en_d_i;
        alu_control_e_o <= alu_control_d_i;
        alu_src_e_o <= alu_src_d_i;

        // data path
        rd_data1_e_o <= rd_data1_d_i;
        rd_data2_e_o <= rd_data2_d_i;
        pc_e_o <= pc_d_i;
        rd_addr1_e_o <= rd_addr1_d_i;
        rd_addr2_e_o <= rd_addr2_d_i;
        wr_addr_e_o <= wr_addr_d_i;
        imm_ext_e_o <= imm_ext_d_i;
        pc_plus_4_e_o <= pc_plus_4_d_i;

    end

endmodule