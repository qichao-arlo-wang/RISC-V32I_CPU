module control_unit (
    input logic [6:0] opcode,          // Opcode from instruction
    input logic [2:0] funct3,          // funct3 field from instruction
    input logic funct7_5,              // funct7_5 (bit 5 of funct7)
    input logic zero,                  // Zero flag
    output logic reg_wr_en,            // Register Write Enable
    output logic mem_wr_en,            // Memory Write Enable
    output logic [2:0] imm_src,        // Immediate source control
    output logic alu_src,              // ALU source (register or immediate)
    output logic result_src,           // Result source (ALU or memory)
    output logic [3:0] alu_control,    // ALU Operation control (updated to 4 bits)
    output logic pc_src                // Program counter source (branch decision)
);

    logic [1:0] alu_op;                // ALU operation control signal
    logic branch;                      // Branch control signal

    // Instantiate Main Decoder
    main_decoder main_dec (
        .opcode_i(opcode),             // Connect opcode
        .funct_3_i(funct3),            // Connect funct3 to funct_3_i
        .reg_wr_en_o(reg_wr_en),       // Connect Register Write Enable
        .mem_wr_en_o(mem_wr_en),       // Connect Memory Write Enable
        .imm_src_o(imm_src),           // Connect Immediate source
        .alu_src_o(alu_src),           // Connect ALU source
        .branch_o(branch),             // Connect Branch control
        .result_src_o(result_src),     // Connect Result source
        .alu_op_o(alu_op)              // Connect ALU operation control
    );

    // Instantiate ALU Decoder
    alu_decoder alu_dec (
        .alu_op_i(alu_op),             // Connect ALU operation
        .funct3_i(funct3),             // Connect funct3 field
        .funct7_5_i(funct7_5),         // Connect funct7_5 bit
        .alu_control_o(alu_control)    // Connect ALU control output
    );

    // Branch decision
    assign pc_src = branch & zero;     // Compute PC source based on branch and zero flag
endmodule
