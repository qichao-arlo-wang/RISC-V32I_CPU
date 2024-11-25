module register_file #(
    parameter REG_COUNT = 32,
    parameter REG_WIDTH = 32
) (
    input logic clk, 
    input logic we3_i,
    input logic [$clog2(REG_COUNT)-1:0] a1_i, a2_i, a3_i, // READ (a1_i, a2_i) and write (a3_i) addresses
    input logic [REG_WIDTH-1:0] wd3_i,

    output logic [REG_WIDTH-1:0] rd1_o, rd2_o // read data output
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

    // write data into the register file on the rising edge of the clock
    always_ff @(posedge clk) begin
        if (we3_i && a3_i != 0) begin
            reg_file[a3_i] <= wd3_i;
        end
        reg_file[0] <= 32'b0; // ensure register 0 always holds the value 0
    end

    // Asynchronous read operation (use = rather than <=)
    always_comb begin
        rd1_o = reg_file[a1_i];
        rd2_o = reg_file[a2_i];
    end
endmodule
