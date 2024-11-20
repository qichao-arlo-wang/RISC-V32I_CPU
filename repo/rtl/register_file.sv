module register_file #(
    parameter REG_COUNT = 32,
    parameter REG_WIDTH = 32
) (
    input logic clk, 
    input logic we3,
    input logic [$clog2(REG_COUNT)-1:0] ad1, ad2, ad3, // READ (ad1, ad2) and write (ad3) addresses
    input logic [REG_WIDTH-1:0] wd3,

    output logic [REG_WIDTH-1:0] rd1, rd2, // read data output
    output logic [REG_WIDTH-1:0] a0
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
        if (we3 && ad3 != 0) begin
            reg_file[ad3] <= wd3;
        end
        reg_file[0] <= 32'b0; // ensure register 0 always holds the value 0
    end

    // Asynchronous read operation
    always_comb begin
        rd1 <= reg_file[rd1];
        rd2 <= reg_file[rd2];
    end
endmodule
