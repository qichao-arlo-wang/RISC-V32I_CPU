// this module is a separate top layer for the first part
// for testing purposes
module test_top_1 #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic pc_src,
    input   logic imm_op,
    output  logic [DATA_WIDTH-1:0] pc    
);

    // internal signal
    logic [DATA_WIDTH-1:0] pc, inc_pc, pc_src, imm_op, branch_pc;

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

    .out(next_PC)
);

// program counter
PC_Reg pc_reg(
    .clk     (clk),
    .rst     (rst),
    .next_PC (next_pc),
    
    .PC      (pc)
);

endmodule
