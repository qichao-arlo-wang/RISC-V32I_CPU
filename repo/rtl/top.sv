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
logic [DATA_WIDTH-1:0] PC, inc_PC, PC_src, ImmOp, branch_PC;

// adder used to add PC and ImmOp
adder branch_pc_adder(
    .in1 (PC),
    .in2 (ImmOp),
    
    .out (branch_PC)
);

// adder used to +4
adder inc_pc_adder(
    .in1 (inc_PC),
    .in2 (32'd4)),

    .out (PC)
);

// mux used to select between branch_PC and inc_PC 
mux pc_mux(
    .in0(inc_PC),
    .in1(branch_PC),
    .sel(PC_src),

    .out(next_PC)
);

// program counter
PC_Reg pc_reg(
    .clk     (clk),
    .rst     (rst),
    .next_PC (next_PC),
    
    .PC      (PC)
);


/// /// BLOCK 2: The Register File, ALU and the related MUX /// ///
// Instruction & fields
logic [DATA_WIDTH-1:0] instruction;
logic [6:0] opcode = instruction[6:0];
logic [2:0] funct3 = instruction[14:12];
logic funct7_5 = instruction[30];

// Control signals
logic RegWrite, MemWrite, ALUsrc, Branch, ResultSrc;
logic [1:0] ImmSrc;
logic [2:0] ALUControl;
logic Zero;

// Immediate
logic [DATA_WIDTH-1:0] immediate;

// Register data 
logic [DATA_WIDTH-1:0] reg_data1, reg_data2, alu_in2, alu_out;

// Instantiate Instruction Memory
Instruction_Memory imem (
    .addr(PC),
    .instruction(instruction)
);

// Instantiate Control Unit
Control_Unit ctrl (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .Zero(Zero),
    .RegWrite(RegWrite),
    .MemWrite(MemWrite),
    .Branch(Branch),
    .ResultSrc(ResultSrc),
    .ALUControl(ALUControl),

    .ALUsrc(ALUsrc),
    .ImmSrc(ImmSrc),
    .PCsrc(PCsrc)
);

// Instantiate Sign-Extension Unit
Sign_Extension_Unit sext (
    .instruction(instruction),
    .ImmSrc(ImmSrc),
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
logic zero;

register_file reg_file (
    .clk(clk),
    .we(we),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .wd(wd),
    .rd1(rd1),
    .rd2(rd2),
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
