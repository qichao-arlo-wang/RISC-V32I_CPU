module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,                  // clock signal
);

/// /// BLOCK 1: instruction memory, pc_plus4_adder, pc_reg and pc_mux /// ///
logic [DATA_WIDTH-1:0] pc, pc_plus_4, pc_target, pc_next; // block 1 internal signals
logic pc_src; // block 2 control signal
logic [DATA_WIDTH-1:0] instr; // block 2 instruction signal

// adder used to +4
adder pc_plus4_adder(
    .in1_i (pc), 
    .in2_i (32'd4),
    .out_o (pc_plus_4)
);

// mux used to select between pc_target and pc_plus_4
mux pc_mux(
    .in0_i(pc_plus_4),
    .in1_i(pc_target),
    .sel_i(pc_src),
    .out_o(pc_next)
);

// Instantiate Instruction Memory
instr_mem instr_mem_inst (
    .addr_i(pc),
    .instr_o(instr)
);

pc_reg pc_reg_inst (
    .clk(clk),
    .pc_next_i(pc_next),
    .pc_o(pc)
);



/// /// BLOCK 2: Register file, control unit, and extend /// ///

// // // control signals
// instr signal has been declared in block 1
logic [24:0] instr_31_7 = instr[31:7];
logic [6:0] op = instr[6:0];
logic [2:0] funct3 = instr[14:12];
logic funct7_5 = instr[30];
logic zero;
// !!! !!! signal pc_src has been declared in block 1 !!! !!!
logic reg_wr_en, mem_wr_en, alu_src, result_src;
logic [1:0] imm_src;
logic [3:0] alu_control;


// // // Register signal
logic [4:0] rd_addr1 = instr[19:15]; // rd_addr1: instr[19:15]
logic [4:0] rd_addr2 = instr[24:20]; // rd_addr2: instr[24:20]
logic [4:0] wr_addr  = instr[11:7];  // wr_addr: instr[11:7]
logic [DATA_WIDTH-1:0] rd_data1, rd_data2;
logic [DATA_WIDTH-1:0] result;

// // // extend block signal
logic [DATA_WIDTH-1:0] imm_ext;

// Instantiate Control Unit
control_unit ctrl (
    .op_i(op),
    .funct3_i(funct3),
    .funct7_5_i(funct7_5),
    .zero_i(zero),

    .pc_src_o(pc_src),
    .result_src_o(result_src),
    .mem_wr_en_o(mem_wr_en),
    .alu_control_o(alu_control),
    .alu_src_o(alu_src),
    .imm_src_o(imm_src),
    .reg_wr_en_o(reg_wr_en)
);

// Instantiate Sign-Extension Unit
sign_exten sext (
    .instr_31_7_i(instr_31_7),
    .imm_src_i(imm_src),
    .imm_ext_o(imm_ext)
);

register_file reg_file_inst (
    .clk(clk),
    .rd_addr1_i(rd_addr1),
    .rd_addr2_i(rd_addr2),
    .wr_addr_i(wr_addr),
    .wr_data_i(result),
    .reg_wr_en_i(reg_wr_en),
    .rd_data1_o(rd_data1),
    .rd_data2_o(rd_data2)
);


/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///

// !!! !!! pc_target has been declared in block 1 !!! !!!

// // ALU signals
logic [DATA_WIDTH-1:0] src_a, src_b, alu_result;
logic eq;
logic [3:0] mem_byte_en;
// // data memory siganls 
logic [DATA_WIDTH-1:0] read_data, write_data;
// logic [DATA_WIDTH-1:0] result;  declared in block 2

// ALU unit
alu alu_inst(
    .src_a_i(src_a),
    .src_b_i(src_b),
    .alu_control_i(alu_control),
    .alu_result_o(alu_result),
    .zero_o(zero)
);

//MUX for src_a (ALU first operand)
mux alu_src_a_mux(
    .in0_i(rd1),  //from reg_file (default operand)
    .in1_i(pc),    //from pc 
    .sel_i(alu_src_a_sel), //new control signal for src_a selection
    .out_o(src_a)
);

// MUX for src_b (ALU second operand)
mux alu_src_b_mux(
    .in0_i(rd2),                 // From register file
    .in1_i(imm_ext),             // Immediate value
    .sel_i(alu_src),             // ALU source control signal
    .out_o(src_b)
);

//MUX for src_a (ALU first operand)
mux alu_src_a_mux(
    .in0(rd1),  //from reg_file (default operand)
    .in1(pc),    //from pc 
    .sel(alu_src_a_sel), //new control signal for src_a selection
    .out(src_a)
);

// MUX for src_b (ALU second operand)
mux alu_src_b_mux(
    .in0(rd2),                 // From register file
    .in1(imm_ext),             // Immediate value
    .sel(alu_src),             // ALU source control signal
    .out(src_b)
);

// mux used between register file and alu unit
mux reg_alu_mux(
    .in0_i(rd2),
    .in1_i(imm_ext),
    .sel_i(alu_src),
    .out_o(src_b)
);

// mux used for data memory
mux data_mem_mux(
    .in0_i(alu_result),
    .in1_i(read_data),
    .sel_i(result_src),
    .out_o(result) 
);

// adder used to add pc and imm_ext
adder alu_adder(
    .in1_i(pc),
    .in2_i(imm_ext),
    .out_o(pc_target)
);

data_mem data_mem_inst(
    .clk_i(clk),
    .addr_i(alu_result),
    .wr_data_i(write_data),
    .wr_en_i(mem_wr_en),
    .byte_en_i(mem_byte_en),

    .rd_data_o(read_data)
)

endmodule
