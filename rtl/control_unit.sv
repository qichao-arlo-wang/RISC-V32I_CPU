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
    logic branch_condition;            // Condition for branching based on funct3 and zero

    // Instantiate Main Decoder
    main_decoder main_dec (
        .opcode(opcode),             // Connect opcode
        .funct_3(funct3),
        .reg_wr_en(reg_wr_en),       // Connect Register Write Enable
        .mem_wr_en(mem_wr_en),       // Connect Memory Write Enable
        .imm_src(imm_src),           // Connect Immediate source
        .alu_src(alu_src),           // Connect ALU source
        .branch(branch),             // Connect Branch control
        .result_src(result_src),     // Connect Result source
        .alu_op(alu_op)              // Connect ALU operation control
    );

    // Instantiate ALU Decoder
    alu_decoder alu_dec (
        .alu_op(alu_op),             // Connect ALU operation
        .funct3(funct3),             // Connect funct3 field
        .funct7_5(funct7_5),         // Connect funct7_5 bit
        .alu_control(alu_control)    // Connect ALU control output
    );

    // Compute Branch Condition
    always_comb begin
        case (funct3)
            3'b000: branch_condition = zero;        // beq: branch if zero is set
            3'b001: branch_condition = ~zero;       // bne: branch if zero is not set
            default: branch_condition = 1'b0;       // Other branch types not implemented here
        endcase
    end

    // Compute Program Counter Source
    assign pc_src = branch & branch_condition;      // PC source considers branch enable and branch condition
endmodule
