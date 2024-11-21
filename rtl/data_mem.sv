module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
) (
    input  logic                   clk,
    input  logic                   we,
    input  logic [ADDR_WIDTH-1:0]  a,
    input  logic [DATA_WIDTH-1:0]  wd,
    output logic [DATA_WIDTH-1:0]  rd
);

    // I wrote this file in 5 min, please someone responsible for this file debug ////////////
    logic [DATA_WIDTH-1:0] data_mem [0:(1 << ADDR_WIDTH)-1];

    always_ff @(posedge clk) begin
        rd <= data_mem[a];
    end

    always_ff @(posedge clk) begin
        if (we) begin
            data_mem[a] <= wd;
        end
    end

endmodule
