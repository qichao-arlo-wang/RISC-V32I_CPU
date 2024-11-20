module register_file #(
    parameter REG_COUNT = 16,
    parameter REG_WIDTH = 32
) (
    input logic clk, 
    input logic we,
    input logic [$clog2(REG_COUNT)-1:0] rs1, rs2, rd, // READ (rs1, rs2) and write (rd) addresses
    input logic [REG_WIDTH-1:0] wd,
    output logic [REG_WIDTH-1:0] rd1, rd2 // read data output
);
    // declare register file
    logic [REG_WIDTH-1:0] reg_file [0:REG_COUNT-1];

    // initialize the register file asynchronously
    // setting all registers to 0
    initial begin
        for (int i = 0; i < REG_COUNT; i++) begin
            reg_file[i] = 32'b0;
        end
    end

    // write data into the resgister file on the rising edge of the clock
    always_ff @(posedge clk) begin
        if (we && rd != 0) begin
            reg_file[rd] <= wd;
        end
        reg_file[0] <= 32'b0; // ensure register 0 always holds the value 0
    end

    // read data from the register file on the rising edge of the clock
    always_ff @(posedge clk) begin
        rd1 <= reg_file[rs1];
        rd2 <= reg_file[rs2];
    end
endmodule
