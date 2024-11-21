module register_file #(
    parameter REG_COUNT = 32,
    parameter REG_WIDTH = 32
) (
    input logic clk, 
    input logic we3,
    input logic [$clog2(REG_COUNT)-1:0] a1, a2, a3, // READ (a1, a2) and write (a3) addresses
    input logic [REG_WIDTH-1:0] wd3,

    output logic [REG_WIDTH-1:0] rd1, rd2, // read data output
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
        if (we3 && a3 != 0) begin
            reg_file[a3] <= wd3;
        end
        reg_file[0] <= 32'b0; // ensure register 0 always holds the value 0
    end

    // Asynchronous read operation(use = rather than <=)
    always_comb begin
        rd1 = reg_file[a1];
        rd2 = reg_file[a2];
    end
endmodule
