module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,                  // clock signal
    input   logic rst,                  // reset signal
    output  logic [DATA_WIDTH-1:0] a0   // output
);

/// /// BLOCK 1: Program counter and related adders /// ///
// internal signals
logic [DATA_WIDTH-1:0] PC, inc_PC, ImmOp, branch_PC, next_PC, instr;
logic PCsrc;

// adder used to add PC and ImmOp
adder branch_pc_adder(
    .in1 (PC),
    .in2 (ImmOp),
    
    .out (branch_PC)
);

// adder used to +4
adder inc_pc_adder(
    .in1 (PC), 
    .in2 (32'd4),

    .out (inc_PC)
);

// mux used to select between branch_pc and inc_pc
mux pc_mux(
    .in0(inc_PC),
    .in1(branch_PC),
    .sel(PCsrc),

    .out(next_PC)
);

// program counter
pc_reg pc_reg(
    .clk     (clk),
    .rst     (rst),
    .next_pc (next_PC),
    
    .pc      (PC)
);


/// /// BLOCK 2: The Register File, ALU and the related MUX /// ///

// Control signals
logic RegWrite, ALUsrc, MemWrite, ResSrc;
logic [1:0] ImmSrc;
logic [2:0] ALUctrl;
logic EQ;

// Instantiate Instruction Memory
instruction_memory imem (
    .addr(PC),
    .instruction(instr)
);

// Register data 
logic [4:0] rs1 = instr[19:15]; // rs1: instruction[19:15]
logic [4:0] rs2 = instr[24:20]; // rs2: instruction[24:20]
logic [4:0] rd  = instr[11:7];  // rd: instruction[11:7]

// Instantiate Control Unit
control_unit ctrl (
    .instruction(instr),
    .zero(EQ),

    .mem_wr_en(MemWrite), 
    .reg_wr_en(RegWrite),
    .alu_control(ALUctrl),
    .alu_src(ALUsrc),
    .imm_src(ImmSrc),
    .pc_src(PCsrc),
    .result_src(ResSrc)
);

// Instantiate Sign-Extension Unit
sign_exten sext (
    .instruction(instr),

    .imm_src(ImmSrc),
    .immediate(ImmOp)
);

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
logic [DATA_WIDTH-1:0] rd1, rd2;
//ALU signals
logic [DATA_WIDTH-1:0] ALUop1, ALUop2, ALUout;

register_file reg_file_inst (
    .clk(clk),
    .ad1(rs1),
    .ad2(rs2),
    .ad3(rd),
    .wd3(ALUout),
    .we3(RegWrite),

    .rd1(ALUop1),
    .rd2(regOp2),
    .a0(a0)
);

alu alu_inst(
    .alu_op1(ALUop1),
    .alu_op2(ALUop2),
    .alu_ctrl(ALUctrl),
    .alu_out(ALUout),
    .eq(EQ)
);

logic [DATA_WIDTH-1:0] regOp2;

mux alu_mux_inst(
    .in0(regOp2),
    .in1(ImmOp),
    .sel(ALUsrc),
    .out(ALUop2)
);

// initial begin
//     we3 =1;
//     ad1 = 5'd1;
//     ad2 = 5'd2;
//     ad3 = 5'd3;
//     sel = 0;
//     alu_ctrl = 4'b0000;
//     #10
//     alu_src = 1;
// end


endmodule
