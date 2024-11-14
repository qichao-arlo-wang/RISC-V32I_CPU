module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0    
);
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
