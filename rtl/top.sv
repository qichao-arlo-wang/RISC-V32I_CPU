module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,     // clock signal
    input   logic trigger,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0
);

logic trigger_latched;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Set trigger_latched based on trigger during reset
        if (trigger) begin
            trigger_latched <= 1;
        end else begin
            trigger_latched <= 0;
        end
    end 
    else if (trigger) begin
        // Standard trigger logic after reset
        trigger_latched <= 1;
    end
end


// // Signal Declare
// stall & flush
logic stall, flush;

// pc related signals
logic [DATA_WIDTH-1:0] pc_f, pc_d;
logic [DATA_WIDTH-1:0] pc_next_f;
logic [DATA_WIDTH-1:0] pc_plus_4_f, pc_plus_4_d, pc_plus_4_e, pc_plus_4_m, pc_plus_4_w;
logic [DATA_WIDTH-1:0] pc_target_e; // pc target e
logic pc_src_e; 
logic [DATA_WIDTH-1:0] instr_f, instr_d; // instruction signal

// control unit signals - Decode
logic [24:0] instr_31_7 = instr_d[31:7];
logic [6:0] op_d = instr_d[6:0];
logic [2:0] funct3_d = instr_d[14:12];
logic [6:0] funct7 = instr_d[31:25];
logic load_flag_d; // flag for whether or not this instruction is load instruction
logic result_src_d, alu_src_d, alu_src_a_sel_d, signed_bit, branch_d;
logic reg_wr_en_d, mem_wr_en_d, data_mem_or_pc_mem_sel_d;
logic [2:0] imm_src_d;
logic [3:0] alu_control_d;
/* verilator lint_off UNUSED */
logic [3:0] mem_byte_en_d;
/* verilator lint_on UNUSED */
logic [DATA_WIDTH-1:0] option_d, option2_d; // for MUX in Execution stage

// control unit signals - Execution
logic [6:0] op_e;
logic [2:0] funct3_e;
logic load_flag_e;
logic result_src_e, alu_src_e, alu_src_a_sel_e, branch_e, branch_condition_e;
logic reg_wr_en_e, mem_wr_en_e, data_mem_or_pc_mem_sel_e;
/* verilator lint_off UNUSED */
logic [3:0] alu_control_e, mem_byte_en_e;
/* verilator lint_on UNUSED */
logic [DATA_WIDTH-1:0] option_e, option2_e; // for MUX in Execution stage

// control unit signals - Mem & Writeback
logic reg_wr_en_m, reg_wr_en_w, mem_wr_en_m, result_src_w, result_src_m, data_mem_or_pc_mem_sel_m, data_mem_or_pc_mem_sel_w;
logic [3:0] mem_byte_en_m;

// Register signals - Decode
logic [4:0] rd_addr1_d = instr_d[19:15]; // rd_addr1: instr[19:15]
logic [4:0] rd_addr2_d = instr_d[24:20]; // rd_addr2: instr[24:20]
logic [4:0] wr_addr_d  = instr_d[11:7];  // wr_addr: instr[11:7]
logic [DATA_WIDTH-1:0] rd_data1_d, rd_data2_d;

// Register signals - Execution
logic [4:0] rd_addr1_e, rd_addr2_e, wr_addr_e;
logic [DATA_WIDTH-1:0] rd_data1_e, rd_data2_e;

// Register signals - Mem & Writeback 
logic [DATA_WIDTH-1:0] rd_data2_m;
logic [4:0] wr_addr_m, wr_addr_w;


// extend block signal
logic [DATA_WIDTH-1:0] imm_ext_d, imm_ext_e;

// ALU signals
logic [DATA_WIDTH-1:0] src_a, src_b;
logic eq_e; // zero flag
logic [DATA_WIDTH-1:0] alu_result_e, alu_result_m, alu_result_w; 

// hazard unit
logic [1:0] forward_a_e;
logic [1:0] forward_b_e;
logic [DATA_WIDTH-1:0] hazard_mux_a_out;
logic [DATA_WIDTH-1:0] hazard_mux_b_out;

// data memory siganls 
logic [DATA_WIDTH-1:0] read_data_m, read_data_w;
logic [31:0] data_to_use;
logic [DATA_WIDTH-1:0] result_w;




// // Stage 1 Fetch - f

/// BLOCK 1: instruction memory, pc_plus4_adder, pc_reg and pc_mux /// ///

// adder used to +4
adder pc_plus4_adder(
    .in1_i (pc_f), 
    .in2_i (32'd4),

    .out_o (pc_plus_4_f)
);

// mux used to select between pc_target and pc_plus_4
mux pc_mux(
    .in0_i(pc_plus_4_f), // PC += 4
    .in1_i(pc_target_e), // branch CHECK THIS
    .sel_i(pc_src_e),

    .out_o(pc_next_f)
);

// Instantiate Instruction Memory
instr_mem instr_mem_inst (
    .addr_i(pc_f),
    .instr_o(instr_f)
);

pc_reg pc_reg_inst (
    .clk(clk & trigger_latched),
    .rst(rst),
    .pc_next_i(pc_next_f),

    .pc_o(pc_f)
);

pipeline_reg_f_d pipeline_reg_f_d_inst (
    .clk_i(clk),
    .stall_i(stall),
    .flush_i(flush),
    .instr_f_i(instr_f),
    .pc_f_i(pc_f),
    .pc_plus_4_f_i(pc_plus_4_f),

    .instr_d_o(instr_d),
    .pc_d_o(pc_d),
    .pc_plus_4_d_o(pc_plus_4_d)
);



// // Stage 2 Decode - d

/// BLOCK 2: Register file, control unit, and extend /// ///
// Instantiate Control Unit
control_unit ctrl (
    .opcode_i(op_d),
    .funct3_i(funct3_d),
    .funct7_i(funct7),

    .reg_wr_en_o(reg_wr_en_d),
    .mem_wr_en_o(mem_wr_en_d),
    .imm_src_o(imm_src_d),
    .alu_src_o(alu_src_d),  
    .result_src_o(result_src_d),  
    .alu_control_o(alu_control_d),
    .byte_en_o(mem_byte_en_d),
    .alu_src_a_sel_o(alu_src_a_sel_d),
    .signed_o(signed_bit),
    .branch_o(branch_d)
);

// Instantiate Sign-Extension Unit
sign_exten sign_exten_inst (
    .instr_31_7_i(instr_31_7),
    .imm_src_i(imm_src_d),
    .signed_i(signed_bit),

    .imm_ext_o(imm_ext_d)
);

register_file reg_file_inst (
    .clk(clk),
    .rd_addr1_i(rd_addr1_d),
    .rd_addr2_i(rd_addr2_d),
    .wr_addr_i(wr_addr_w),
    .wr_data_i(result_w),
    .reg_wr_en_i(reg_wr_en_w),

    .rd_data1_o(rd_data1_d),
    .rd_data2_o(rd_data2_d),
    .a0(a0)
);

always_comb begin
    case (op_d)
        7'b0110111: option_d = 32'b0; // LUI
        default: option_d = pc_d; // AUIPC
    endcase
end

always_comb begin
    case (op_d)
        7'b1100111: begin //JAL
            option2_d = rd_data1_d;
        end
        default: option2_d = pc_d; // JALR stage for pc need defined for option2_d
    endcase
end

always_comb begin
    case (op_d)
        7'b1101111: data_mem_or_pc_mem_sel_d = 1;
        7'b1100111: data_mem_or_pc_mem_sel_d = 1;
        default: data_mem_or_pc_mem_sel_d = 0;
    endcase
end

// Calculate Load _flag
always_comb begin
    case (op_d)
        7'b0000011: load_flag_d = 1; // Load Instructions
        default: load_flag_d = 0; // Other instructions
    endcase
end

pipeline_reg_d_e pipeline_reg_d_e_inst (

    .clk_i(clk),
    .flush_i(flush),
    .stall_i(stall),

    // Control Unit Signals
    .reg_wr_en_d_i(reg_wr_en_d),
    .result_src_d_i(result_src_d),
    .mem_wr_en_d_i(mem_wr_en_d),
    .mem_byte_en_d_i(mem_byte_en_d),
    .alu_control_d_i(alu_control_d),
    .alu_src_d_i(alu_src_d),
    .alu_src_a_sel_d_i(alu_src_a_sel_d),
    .option_d_i(option_d),
    .option2_d_i(option2_d),
    .data_mem_or_pc_mem_sel_d_i(data_mem_or_pc_mem_sel_d),
    .branch_d_i(branch_d),
    .opcode_d_i(op_d),
    .funct3_d_i(funct3_d),
    .load_flag_d_i(load_flag_d),

    .reg_wr_en_e_o(reg_wr_en_e),
    .result_src_e_o(result_src_e),
    .mem_wr_en_e_o(mem_wr_en_e),
    .mem_byte_en_e_o(mem_byte_en_e),
    .alu_control_e_o(alu_control_e),
    .alu_src_e_o(alu_src_e),
    .alu_src_a_sel_e_o(alu_src_a_sel_e),
    .option_e_o(option_e),
    .option2_e_o(option2_e),
    .data_mem_or_pc_mem_sel_e_o(data_mem_or_pc_mem_sel_e),
    .branch_e_o(branch_e),
    .opcode_e_o(op_e),
    .funct3_e_o(funct3_e),
    .load_flag_e_o(load_flag_e),

    // Data Path Signals
    .rd_data1_d_i(rd_data1_d),
    .rd_data2_d_i(rd_data2_d),
    .rd_addr1_d_i(rd_addr1_d),
    .rd_addr2_d_i(rd_addr2_d),
    .wr_addr_d_i(wr_addr_d),
    .imm_ext_d_i(imm_ext_d),
    .pc_plus_4_d_i(pc_plus_4_d),

    .rd_data1_e_o(rd_data1_e),
    .rd_data2_e_o(rd_data2_e),
    .rd_addr1_e_o(rd_addr1_e),
    .rd_addr2_e_o(rd_addr2_e),
    .wr_addr_e_o(wr_addr_e),
    .imm_ext_e_o(imm_ext_e),
    .pc_plus_4_e_o(pc_plus_4_e)
);


// // Stage 3 Execution  -e
/// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// 

// Compute Program Counter Source
always_comb begin
    case (op_e)
        7'b1100111: pc_src_e = branch_e;                  // JALR
        7'b1101111: pc_src_e = branch_e;                  //JAL
        default: pc_src_e = branch_e & branch_condition_e;  // B instructions
    endcase
end

// ALU unit
alu alu_inst(
    .src_a_i(src_a),
    .src_b_i(src_b),
    .alu_control_i(alu_control_e),

    .alu_result_o(alu_result_e),
    .zero_o(eq_e)
);

// Compute Branch Condition
always_comb begin
    case (funct3_e)
        3'b000: branch_condition_e = eq_e;                      // beq: branch if zero is set
        3'b001: branch_condition_e = ~eq_e;                     // bne: branch if zero is not set
        3'b100: branch_condition_e = ($signed(alu_result_e) < 0);          // blt
        3'b101: branch_condition_e = eq_e | ($signed(alu_result_e) < 0); // bge
        3'b110: branch_condition_e = (alu_result_e < 0);           //bltu 
        3'b111: branch_condition_e = eq_e | (alu_result_e > 0);  //bgeu
        default: branch_condition_e = 1'b0;                       // Other branch types not implemented here
    endcase
end

//MUX for src_a (ALU first operand)
mux alu_src_a_mux(
    .in0_i(hazard_mux_a_out),// From hazard mux a
    .in1_i(option_e),         // only for LUi and AUIPC
    .sel_i(alu_src_a_sel_e),  // new control signal for src_a selection

    .out_o(src_a)
);


// MUX for src_b (ALU second operand)
mux alu_src_b_mux(
    .in0_i(hazard_mux_b_out),  // From hazard mux b
    .in1_i(imm_ext_e),          // Immediate value
    .sel_i(alu_src_e),          // ALU source control signal

    .out_o(src_b)
);

// adder used to add pc and imm_ext
adder alu_adder(
    .in1_i(option2_e),
    .in2_i(imm_ext_e),
    
    .out_o(pc_target_e)
);


// hazard MUX for src_a 
mux4 hazard_a (
    .in0_i(rd_data1_e),      // from register file (default operand)
    .in1_i(result_w),        // from writeback stage result
    .in2_i(alu_result_m),     // from memory stage ALU result
    .in3_i(0),               // default zero
    .sel_i(forward_a_e),      // forward control signal for src_a

    .out_o(hazard_mux_a_out)          
);

// hazard MUX for writedata 
mux4 hazard_b (
    .in0_i(rd_data2_e),       // from register file
    .in1_i(result_w),        // from writeback stage result
    .in2_i(alu_result_m),     // from memory stage ALU result
    .in3_i(0),               // default zero
    .sel_i(forward_b_e),      // forward control signal for writedata

    .out_o(hazard_mux_b_out)    
);


pipeline_reg_e_m pipeline_e_m_inst (
    // Control Unit
    .clk_i(clk),
    .reg_wr_en_e_i(reg_wr_en_e),
    .result_src_e_i(result_src_e),
    .mem_wr_en_e_i(mem_wr_en_e),
    .mem_byte_en_e_i(mem_byte_en_e),
    .data_mem_or_pc_mem_sel_e_i(data_mem_or_pc_mem_sel_e),

    .reg_wr_en_m_o(reg_wr_en_m),
    .result_src_m_o(result_src_m),
    .mem_wr_en_m_o(mem_wr_en_m),
    .mem_byte_en_m_o(mem_byte_en_m),
    .data_mem_or_pc_mem_sel_m_o(data_mem_or_pc_mem_sel_m),

    // Data Path
    .alu_result_e_i(alu_result_e),
    .rd_data2_e_i(hazard_mux_b_out),
    .wr_addr_e_i(wr_addr_e),
    .pc_plus_4_e_i(pc_plus_4_e),

    .alu_result_m_o(alu_result_m),
    .rd_data2_m_o(rd_data2_m),
    .wr_addr_m_o(wr_addr_m),
    .pc_plus_4_m_o(pc_plus_4_m)
);

// // Stage 4 Memory  -m

data_mem data_mem_inst(
    .clk(clk),
    .addr_i(alu_result_m),
    .wr_data_i(rd_data2_m),
    .wr_en_i(mem_wr_en_m),
    .byte_en_i(mem_byte_en_m),

    .rd_data_o(read_data_m)
);


pipeline_reg_m_w pipeline_m_w_inst ( 
    // Control Unit
    .clk_i(clk),
    .reg_wr_en_m_i(reg_wr_en_m),
    .result_src_m_i(result_src_m),
    .data_mem_or_pc_mem_sel_m_i(data_mem_or_pc_mem_sel_m),

    .reg_wr_en_w_o(reg_wr_en_w),
    .result_src_w_o(result_src_w),
    .data_mem_or_pc_mem_sel_w_o(data_mem_or_pc_mem_sel_w),

    // Data Path
    .alu_result_m_i(alu_result_m),
    .read_data_m_i(read_data_m),
    .wr_addr_m_i(wr_addr_m),
    .pc_plus_4_m_i(pc_plus_4_m),

    .alu_result_w_o(alu_result_w),
    .read_data_w_o(read_data_w),
    .wr_addr_w_o(wr_addr_w),
    .pc_plus_4_w_o(pc_plus_4_w)
);


// // Stage 5 Writeback  -w
mux data_mem_pc_next(
    .in0_i(read_data_w),
    .in1_i(pc_plus_4_w),
    .sel_i(data_mem_or_pc_mem_sel_w),

    .out_o(data_to_use)
);

// mux used for data memory
mux data_mem_mux(
    .in0_i(alu_result_w),
    .in1_i(data_to_use),
    .sel_i(result_src_w),

    .out_o(result_w) 
);


hazard_unit hazard_unit_inst ( 
    // Detect lw for stall
    .rd_addr1_d_i(rd_addr1_d),
    .rd_addr2_d_i(rd_addr2_d),
    .wr_addr_e_i(wr_addr_e),
    .load_flag_e_i(load_flag_e),
    .pc_src_i(pc_src_e),

    // Data forwarding signals
    .rd_addr1_e_i(rd_addr1_e),
    .rd_addr2_e_i(rd_addr2_e),
    .wr_addr_m_i(wr_addr_m),
    .wr_addr_w_i(wr_addr_w),
    .reg_wr_en_m_i(reg_wr_en_m),
    .reg_wr_en_w_i(reg_wr_en_w),
    
    .forward_a_e_o(forward_a_e),
    .forward_b_e_o(forward_b_e),
    .stall_o(stall),
    .flush_o(flush)
);


endmodule
