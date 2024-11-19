// this module is a separate top layer for the first part
// for testing purposes
module test_top_1 #(
    DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    input   logic PCsrc,
    input   logic ImmOp,
    output  logic [DATA_WIDTH-1:0] PC    
);

    // internal signal
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

endmodule
