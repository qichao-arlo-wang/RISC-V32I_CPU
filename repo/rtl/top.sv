module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,                  // clock signal
    input   logic rst,                  // reset signal
    output  logic [DATA_WIDTH-1:0] a0   // register a0 output
);

/// /// BLOCK 1: Program counter and related adders /// ///
// internal signals
logic [DATA_WIDTH-1:0] pc, inc_pc, imm_op, branch_pc, next_pc;
logic pc_src;

// adder used to add PC and ImmOp
adder branch_pc_adder(
    .in1 (pc),
    .in2 (imm_op),
    
    .out (branch_pc)
);

// adder used to +4
adder inc_pc_adder(
    .in1 (pc), 
    .in2 (32'd4),

    .out (inc_pc)
);

// mux used to select between branch_pc and inc_pc
mux pc_mux(
    .in0(inc_pc),
    .in1(branch_pc),
    .sel(pc_src),

    .out(next_pc)
);

// program counter
pc_reg pc_reg(
    .clk     (clk),
    .rst     (rst),
    .next_pc (next_pc),
    
    .pc      (pc)
);


/// /// BLOCK 2: The Register File, ALU and the related MUX /// ///
// Instruction & fields
logic [DATA_WIDTH-1:0] instruction;
logic [6:0] opcode = instruction[6:0];
logic [2:0] funct3 = instruction[14:12];
logic funct7_5 = instruction[30];

// Control signals
logic reg_wr_en, mem_wr_en, alu_src, result_src;
logic [1:0] imm_src;
logic [2:0] alu_control;
logic zero;

// Register data 
logic [4:0] rs1 = instruction[19:15]; // rs1: instruction[19:15]
logic [4:0] rs2 = instruction[24:20]; // rs2: instruction[24:20]
logic [4:0] rd  = instruction[11:7];  // rd: instruction[11:7]

// Instantiate Instruction Memory
instruction_memory imem (
    .addr(pc),
    .instruction(instruction)
);

// Instantiate Control Unit
control_unit ctrl (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .zero(zero),

    .pc_src(pc_src),
    .result_src(result_src),
    .mem_wr_en(mem_wr_en),
    .alu_control(alu_control),
    .alu_src(alu_src),
    .imm_src(imm_src),
    .reg_wr_en(reg_wr_en)
);

// Instantiate Sign-Extension Unit
sign_exten sext (
    .instruction(instruction),

    .imm_src(imm_src),
    .imm_op(imm_op)
);

/*
// PC update logic
always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'b0;
    else
        pc <= next_pc;
end

assign next_pc = (PCsrc) ? pc + (imm_op << 1) : pc + 4;
*/


/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///
//Register_file signals
logic we3;

logic [DATA_WIDTH-1:0] wd3, rd1, rd2;
//ALU signals
logic [DATA_WIDTH-1:0] alu_op1, alu_op2, alu_out;
logic [3:0] alu_ctrl;
logic eq;

register_file reg_file_inst (
    .clk(clk),
    .ad1(rs1),
    .ad2(rs2),
    .ad3(rd),
    .we3(we3),
    .wd3(wd3),

    .rd1(rd1),
    .rd2(rd2),
    .a0(a0)
);

alu alu_inst(
    .alu_op1(alu_op1),
    .alu_op2(alu_op2),
    .alu_ctrl(alu_ctrl),

    .alu_out(alu_out),
    .eq(eq)
);

mux alu_mux_inst(
    .in0(rd2),
    .in1(imm_op),
    .sel(alu_src),
    .out(alu_op2)
);

initial begin
    we3 =1;
    rs1 = 5'd1;
    rs2 = 5'd2;
    rd = 5'd3;
    alu_ctrl = 4'b0000;
    alu_src = 1;
end

assign a0 = wd3;
endmodule
