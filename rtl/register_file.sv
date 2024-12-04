module register_file #(
    parameter REG_COUNT = 32,
    parameter REG_WIDTH = 32,
    parameter ADR_WIDTH = 5
) (
    input logic clk, 
    input logic reg_wr_en_i,
    input logic [ADR_WIDTH-1:0] rd_addr1_i, rd_addr2_i, wr_addr_i, // READ (read_addr1_i, read_addr2_i) and write (write_addr_i) addresses
    input logic [REG_WIDTH-1:0] wr_data_i,

    output logic [REG_WIDTH-1:0] rd_data1_o, rd_data2_o, // read data output
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

    // write data into the register file on the rising edge of the clock
    always_ff @(negedge clk) begin
        if (reg_wr_en_i && wr_addr_i != 0) begin
            reg_file[wr_addr_i] <= wr_data_i;
        end
        reg_file[0] <= 32'b0; // ensure register 0 always holds the value 0
    end

    // Asynchronous read operation (use = rather than <=)
    always_comb begin
        rd_data1_o = reg_file[rd_addr1_i];
        rd_data2_o = reg_file[rd_addr2_i];
        a0 = reg_file[10];
    end
endmodule
