module data_mem #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10
) (
    input  logic                   clk,
    input  logic [ADDR_WIDTH-1:0]  a,  // mem address
    input  logic                   we, // mem write enable
    input  logic [DATA_WIDTH-1:0]  wd, // mem write data

    output logic [DATA_WIDTH-1:0]  rd  // mem read data
);

    //  memory array - size determined by ADDR_WIDTH 
    logic [DATA_WIDTH-1:0] data_mem [0:(1 << ADDR_WIDTH)-1]; 

    // initialise memory array to a known state 
    // // // for simulation purposes only // // //
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
