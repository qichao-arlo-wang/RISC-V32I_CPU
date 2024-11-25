module control_unit (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic funct7_5,
    input logic zero,
    output logic reg_wr_en,
    output logic mem_wr_en,
    output logic [2:0] imm_src,
    output logic alu_src,
    output logic result_src,
    output logic [2:0] alu_control,
    output logic pc_src
);

    logic [1:0] alu_op;
    logic branch;
    
    // Instantiate Main Decoder
    main_decoder main_dec (
        .opcode_i(opcode_i),
        .reg_wr_en_o(reg_wr_en_o),
        .mem_wr_en_o(mem_wr_en_o),
        .imm_src_o(imm_src_o),
        .alu_src_o(alu_src_o),
        .branch_o(branch),
        .result_src_o(result_src_o),
        .alu_op_o(alu_op)
    );

    // Instantiate ALU Decoder
    alu_decoder alu_dec (
        .alu_op_i(alu_op),
        .funct3_i(funct3_i),
        .funct7_5_i(funct7_5_i),
        .alu_control_o(alu_control_o)
    );

    // Branch decision
    assign pc_src_o = branch & zero_i;
endmodule
