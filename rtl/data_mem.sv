module data_mem (
    input  logic        clk,
    input  logic [31:0] addr_i,    // mem address
    input  logic        wr_en_i,   // mem write enable
    input  logic [31:0] wr_data_i, // mem write data
    input  logic [3:0]  byte_en_i, // byte enable

    output logic [31:0] rd_data_o  // mem read data
);

    localparam int ADDR_MAX = 4095;
    // 1024 x 8-bit memory
    logic [7:0] mem [0:ADDR_MAX];

    // Mask for 4-byte alignment
    localparam int WORD_ALIGN_MASK = 32'hFFFFFFFC;

    // Internal signal for address error detection
    logic addr_error;

    // Address alignment and range error detection
    always_comb begin
        // Default: no error
        addr_error = 1'b0;

        // Check for 4-byte alignment
        if ((addr_i & ~WORD_ALIGN_MASK) != 0) begin
            addr_error = 1'b1; // Address misalignment
        end
        
        // Check if address is within valid range
        else if (addr_i > ADDR_MAX - 3) begin
            addr_error = 1'b1; // Address out of range
        end
    end


  // Write logic
    always_ff @(posedge clk) begin
        if (wr_en_i && !addr_error) begin
            if (byte_en_i[0]) mem[addr_i]   <= wr_data_i[7:0];
            if (byte_en_i[1]) mem[addr_i+1] <= wr_data_i[15:8];
            if (byte_en_i[2]) mem[addr_i+2] <= wr_data_i[23:16];
            if (byte_en_i[3]) mem[addr_i+3] <= wr_data_i[31:24];
        end
    end

    
    // Read logic
    always_comb begin
        if (addr_error) begin
            rd_data_o = 32'hDEADBEEF; // Return error value if address is invalid
        end else begin
            rd_data_o = {mem[addr_i], mem[addr_i+1], mem[addr_i+2], mem[addr_i+3]};
        end
    end

endmodule
