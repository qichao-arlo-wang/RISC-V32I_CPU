module pipeline_reg_d_e #(
    parameter WIDTH = 32
)(
    input logic clk_i,
    input logic flush_i,
    input logic stall_i,

    // Control unit inputs
    input logic reg_wr_en_d_i,
    input logic result_src_d_i,
    input logic mem_wr_en_d_i,
    input logic [3:0] mem_byte_en_d_i,
    input logic [3:0] alu_control_d_i,
    input logic alu_src_d_i,
    input logic alu_src_a_sel_d_i,
    input logic [WIDTH-1:0] option_d_i,
    input logic [WIDTH-1:0] option2_d_i,
    input logic data_mem_or_pc_mem_sel_d_i,
    input logic branch_d_i,
    input logic [6:0] opcode_d_i,
    input logic [2:0] funct3_d_i,
    input logic load_flag_d_i,

    // Control unit outputs
    output logic reg_wr_en_e_o,
    output logic result_src_e_o,
    output logic mem_wr_en_e_o,
    output logic [3:0] mem_byte_en_e_o,
    output logic [3:0] alu_control_e_o,
    output logic alu_src_e_o,
    output logic alu_src_a_sel_e_o,
    output logic [WIDTH-1:0] option_e_o,
    output logic [WIDTH-1:0] option2_e_o,
    output logic data_mem_or_pc_mem_sel_e_o,
    output logic branch_e_o,
    output logic [6:0] opcode_e_o,
    output logic [2:0] funct3_e_o,
    output logic load_flag_e_o,

    // Data path inputs
    input logic [WIDTH-1:0] rd_data1_d_i,
    input logic [WIDTH-1:0] rd_data2_d_i,
    input logic [4:0] rd_addr1_d_i,
    input logic [4:0] rd_addr2_d_i,
    input logic [4:0] wr_addr_d_i,
    input logic [WIDTH-1:0] imm_ext_d_i,
    input logic [WIDTH-1:0] pc_plus_4_d_i,

    // Data path outputs
    output logic [WIDTH-1:0] rd_data1_e_o,
    output logic [WIDTH-1:0] rd_data2_e_o,
    output logic [4:0] rd_addr1_e_o,
    output logic [4:0] rd_addr2_e_o,
    output logic [4:0] wr_addr_e_o,
    output logic [WIDTH-1:0] imm_ext_e_o,
    output logic [WIDTH-1:0] pc_plus_4_e_o
);

always_ff @(posedge clk_i) begin
    if (flush_i || stall_i) begin
        // Flush some control signalbranch-related signals
        mem_wr_en_e_o <= 0;
        reg_wr_en_e_o <= 0;
        branch_e_o <= 0;
        opcode_e_o <= 0;
        funct3_e_o <= 0;
        

        // propagate all other control /data path signals
        result_src_e_o <= result_src_d_i;
        mem_wr_en_e_o <= mem_wr_en_d_i;
        alu_control_e_o <= alu_control_d_i;
        alu_src_e_o <= alu_src_d_i;
        alu_src_a_sel_e_o <= alu_src_a_sel_d_i;
        option_e_o <= option_d_i;
        option2_e_o <= option2_d_i;
        data_mem_or_pc_mem_sel_e_o <= data_mem_or_pc_mem_sel_d_i;
        load_flag_e_o <= load_flag_d_i;

        rd_data1_e_o <= rd_data1_d_i;
        rd_data2_e_o <= rd_data2_d_i;
        rd_addr1_e_o <= rd_addr1_d_i;
        rd_addr2_e_o <= rd_addr2_d_i;
        wr_addr_e_o <= wr_addr_d_i;
        imm_ext_e_o <= imm_ext_d_i;
        pc_plus_4_e_o <= pc_plus_4_d_i;

    end /*else if (stall_i) begin
        // On stall, hold current outputs (no updates)
        reg_wr_en_e_o <= reg_wr_en_e_o;
        result_src_e_o <= result_src_e_o;
        mem_wr_en_e_o <= mem_wr_en_e_o;
        mem_byte_en_e_o <= mem_byte_en_e_o;
        alu_control_e_o <= alu_control_e_o;
        alu_src_e_o <= alu_src_e_o;
        alu_src_a_sel_e_o <= alu_src_a_sel_e_o;
        option_e_o <= option_e_o;
        option2_e_o <= option2_e_o;
        data_mem_or_pc_mem_sel_e_o <= data_mem_or_pc_mem_sel_e_o;
        load_flag_e_o <= load_flag_d_i;// change this

        branch_e_o <= branch_e_o;
        opcode_e_o <= opcode_e_o;
        funct3_e_o <= funct3_e_o;

        rd_data1_e_o <= rd_data1_e_o;
        rd_data2_e_o <= rd_data2_e_o;
        rd_addr1_e_o <= rd_addr1_e_o;
        rd_addr2_e_o <= rd_addr2_e_o;
        wr_addr_e_o <= wr_addr_e_o;
        imm_ext_e_o <= imm_ext_e_o;
        pc_plus_4_e_o <= pc_plus_4_e_o;

    end */else begin
        // Normal operation: pass signals from Decode stage to Execute stage
        reg_wr_en_e_o <= reg_wr_en_d_i;
        result_src_e_o <= result_src_d_i;
        mem_wr_en_e_o <= mem_wr_en_d_i;
        mem_byte_en_e_o <= mem_byte_en_d_i;
        alu_control_e_o <= alu_control_d_i;
        alu_src_e_o <= alu_src_d_i;
        alu_src_a_sel_e_o <= alu_src_a_sel_d_i;
        option_e_o <= option_d_i;
        option2_e_o <= option2_d_i;
        data_mem_or_pc_mem_sel_e_o <= data_mem_or_pc_mem_sel_d_i;
        load_flag_e_o <= load_flag_d_i;

        branch_e_o <= branch_d_i;
        opcode_e_o <= opcode_d_i;
        funct3_e_o <= funct3_d_i;

        rd_data1_e_o <= rd_data1_d_i;
        rd_data2_e_o <= rd_data2_d_i;
        rd_addr1_e_o <= rd_addr1_d_i;
        rd_addr2_e_o <= rd_addr2_d_i;
        wr_addr_e_o <= wr_addr_d_i;
        imm_ext_e_o <= imm_ext_d_i;
        pc_plus_4_e_o <= pc_plus_4_d_i;
    end
end

endmodule
