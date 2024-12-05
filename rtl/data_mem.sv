module data_mem (
    input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [31:0] addr_i,    // mem address
    /* verilator lint_on UNUSED */
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
);

    // total memory size 128KB from 0x0000 0000 to 0x0001 FFFF
    // data_array from 0x0001 0000 to 0x0001 FFFF
    // pdf_array from 0x0000 0100 to 0x0000 01FF
    // reserved mem from 0x0000 0000 to 0x0000 00FF
    localparam DATA_MEM_SIZE = 128 * 1024; // 128KB
    logic [31:0] mem [0:DATA_MEM_SIZE-1];

    // Initialize data_arrary
    initial begin
        $display("LOADING DATA MEMORY.");
        
        // the default path when running the simulation is the tests directory
        // load data.hex into data_array with an offset of 0x0001 0000
        $readmemh("/root/Documents/Group-9-RISC-V/tb/test_out/F1Assembly/data.hex", mem, 32'h00010000); 
    end

    // Synchronous logic for both store and load
    always_ff @(posedge clk) begin
        // store logic
        if (wr_en_i) begin
            case (byte_en_i)
                // byte (8 bits)
                4'b0001: mem[addr_i][7:0]  <= wr_data_i[7:0];
                // half word (16 bits)
                4'b0011: mem[addr_i][15:0] <= wr_data_i[15:0];
                // word (32 bits)
                4'b1111: mem[addr_i]       <= wr_data_i;
                default: $display("Warning: Unrecognized byte enable: %b. No data written.", byte_en_i);
            endcase
        end
            // $display("%h", {mem[addr_i+3], mem[addr_i+2], mem[addr_i+1], mem[addr_i]});
            
        // case (byte_en_i)
        //     // byte (8 bits)
        //     4'b0001: rd_data_o <= {24'b0, mem[addr_i][7:0]};
        //     // half word (16 bits)
        //     4'b0011: rd_data_o <= {16'b0, mem[addr_i][15:0]};
        //     // word (32 bits)
        //     4'b1111: rd_data_o <= {mem[addr_i][31:0]};
        //     // default case
        //     default: rd_data_o <= rd_data_o;
        // endcase
    end

    // Asynchronous read logic
    always_comb begin
        case (byte_en_i)
            4'b0001: rd_data_o = {24'b0, mem[addr_i][7:0]};
            4'b0011: rd_data_o = {16'b0, mem[addr_i][15:0]};
            4'b1111: rd_data_o = mem[addr_i][31:0];
            default: rd_data_o = 32'hDEADBEEF;
        endcase
    end
endmodule
