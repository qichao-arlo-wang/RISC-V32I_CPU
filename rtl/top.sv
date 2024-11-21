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
    .in1 (pc), 
    .in2 (32'd4),
    .out (pc_plus_4)
);

// mux used to select between pc_target and pc_plus_4
mux pc_mux(
    .in0(pc_plus_4),
    .in1(pc_target),
    .sel(pc_src),
    .out(pc_next)
);

// Instantiate Instruction Memory
instr_mem instr_mem_inst (
    .addr(pc),
    .instr(instr)
);

pc_reg pc_reg_inst (
    .clk(clk),
    .pc_next(pc_next),
    .pc(pc)
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
logic [4:0] a1 = instr[19:15]; // a1: instr[19:15]
logic [4:0] a2 = instr[24:20]; // a2: instr[24:20]
logic [4:0] a3  = instr[11:7];  // a3: instr[11:7]
logic [DATA_WIDTH-1:0] rd1, rd2;
logic [DATA_WIDTH-1:0] result;

// // // extend block signal
logic [DATA_WIDTH-1:0] imm_ext;

// Instantiate Control Unit
control_unit ctrl (
    .op(op),
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
    .instr_31_7(instr_31_7),
    .imm_src(imm_src),
    .imm_ext(imm_ext)
);

register_file reg_file_inst (
    .clk(clk),
    .a1(a1),
    .a2(a2),
    .a3(a3),
    .wd3(result),
    .we3(reg_wr_en),
    .rd1(rd1),
    .rd2(rd2),
);

/*
// PC update logic
always_ff @(posedge clk or posedge rst) begin
    if (rst)
        pc <= 32'b0;
    else
        pc <= pc_next;
end

assign pc_next = (PCsrc) ? pc + (imm_op << 1) : pc + 4;
*/



/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///

// !!! !!! pc_target has been declared in block 1 !!! !!!

// // ALU signals
logic [DATA_WIDTH-1:0] src_a, src_b, alu_result;
logic eq;

// // data memory siganls 
logic [DATA_WIDTH-1:0] read_data, write_data;
// logic [DATA_WIDTH-1:0] result;  declared in block 2

// ALU unit
alu alu_inst(
    .src_a(src_a),
    .src_b(src_b),
    .alu_control(alu_control),
    .alu_result(alu_result),
    .zero(zero)
);

// mux used between register file and alu unit
mux reg_alu_mux(
    .in0(rd2),
    .in1(imm_ext),
    .sel(alu_src),
    .out(src_b)
);

// mux used for data memory
mux data_mem_mux(
    .in0(alu_result),
    .in1(read_data),
    .sel(result_src),
    .out(result) 
);

// adder used to add pc and imm_ext
adder alu_adder(
    .in1(pc),
    .in2(imm_ext),
    .out(pc_target)
);

data_mem data_mem_inst(
    .clk(clk),
    .a(alu_result),
    .wd(write_data),
    .we(mem_wr_en),
    .rd(read_data)
)

endmodule
