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

    //  memory array - size determined by ADDR_WIDTH 
    logic [DATA_WIDTH-1:0] data_mem [0:(1 << ADDR_WIDTH)-1]; 

    //initialise memory array to a known state (this is optional!! for simulation purposes!!!)
    initial begin
        for (int i = 0; i < (1 << ADDR_WIDTH); i++) begin
            data_mem[i] = '0;
        end
    end

    //memory read and write operations
    always_ff @(posedge clk) begin
        if (we) begin
            data_mem[a] <= wd;
            rd <= wd; //read after write : rd reflects rewly written value
        end else begin
            rd <= data_mem[a];
        end
    end

endmodule
