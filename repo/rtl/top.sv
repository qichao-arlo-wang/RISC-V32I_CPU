module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,                  // clock signal
    input   logic rst,                  // reset signal
    output  logic [DATA_WIDTH-1:0] a0   // register a0 output
);

assign a0 = 32'd5;


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
    .in1 (inc_pc),
    .in2 (32'd4),

    .out (pc)
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
logic reg_write, mem_write, alu_src, branch, result_src;
logic [1:0] imm_src;
logic [2:0] alu_control;
logic zero;

// Immediate
logic [DATA_WIDTH-1:0] immediate;

// Register data 
logic [DATA_WIDTH-1:0] reg_data1, reg_data2, alu_in2, alu_out;

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
    .reg_write(reg_write),
    .mem_write(mem_write),
    .branch(branch),
    .result_src(result_src),
    .alu_control(alu_control),

    .alu_src(alu_src),
    .imm_src(imm_src),
    .pc_src(pc_src)
);

// Instantiate Sign-Extension Unit
sign_exten sext (
    .instruction(instruction),
    .imm_src(imm_src),
    .immediate(immediate)
);

// Output a0 register content
assign a0 = reg_data1; // Register a0 mapped to reg_data1

/*
// PC update logic
always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'b0;
    else
        pc <= next_pc;
end

assign next_pc = (PCsrc) ? pc + (immediate << 1) : pc + 4;
*/


/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///
//Register_file signals
logic we;
logic [4:0] rs1, rs2, rd;
logic [DATA_WIDTH-1:0] wd, rd1, rd2;
//ALU signals
logic [DATA_WIDTH-1:0] alu_a, alu_b, alu_result;
logic [3:0] alu_ctrl;
// logic zero;   declared in block 2

register_file reg_file_inst (
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2)
);

alu alu_inst(
    .a(alu_a),
    .b(alu_b),
    .alu_ctrl(alu_ctrl),
    .result(alu_result),
    .zero(zero)
);

mux#(.DATA_WIDTH(DATA_WIDTH)) mux_inst(
    .in0(rd1),
    .in1(alu_result),
    .sel(sel),
    .out(wd)
);

initial begin
    we =1;
    rs1 = 5'd1;
    rs2 = 5'd2;
    rd = 5'd3;
    sel = 0;
    alu_ctrl = 4'b0000;
    #10
    sel = 1;
end

assign alu_a = rd1;
assign alu_b = rd2;
assign a0 = wd;


endmodule
