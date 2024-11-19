module register_file (
    input logic clk, 
    input logic we,
    input logic [4:0] rs1, rs2, //read register address
    input logic [4:0] rd, //write register address
    input logic [31:0] wd, //write data
    output logic [31:0] rd1, rd2 // read data output
);
    logic [31:0] reg_file [0:15];

    assign rd1 = reg_file[rs1];
    assign rd2 = reg_file[rs2];

    always_ff @(posedge clk) begin
        if (we && rd != 0) begin
            reg_file[rd] <= wd;
        end
    end
endmodule
