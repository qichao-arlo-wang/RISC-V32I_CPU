module top #(
    parameter DATA_WIDTH = 32
) (
    input   logic clk,     // clock signal
    input   logic trigger,
    input   logic rst,
    output  logic [DATA_WIDTH-1:0] a0  // Already declared
    // output  logic [DATA_WIDTH-1:0] pc,  // Add this
    // output  logic [DATA_WIDTH-1:0] instr // Add this
);

logic trigger_latched;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Set trigger_latched based on trigger during reset
        if (trigger) begin
            trigger_latched <= 1;
        end else begin
            trigger_latched <= 0;
        end
    end 
    else if (trigger) begin
        // Standard trigger logic after reset
        trigger_latched <= 1;
    end
end


/// /// BLOCK 1: instruction memory, pc_plus4_adder, pc_reg and pc_mux /// ///
logic [DATA_WIDTH-1:0] pc, pc_plus_4, pc_target, pc_next; // block 1 internal signals
logic pc_src; // Control signal
logic [DATA_WIDTH-1:0] instr; // Instruction signal


    // Internal connections
    //logic [DATA_WIDTH-1:0] internal_pc, internal_instr;

    // Connect internal signals to top-level outputs
    // assign pc = internal_pc;
    // assign instr = internal_instr;

// adder used to +4
adder pc_plus4_adder(
    .in1_i (pc), 
    .in2_i (32'd4),

    .out_o (pc_plus_4)
);

// mux used to select between pc_target and pc_plus_4
mux pc_mux(
    .in0_i(pc_plus_4), // PC += 4
    .in1_i(pc_target), // branch
    .sel_i(pc_src),

    .out_o(pc_next)
);

// Instantiate Instruction Memory
instr_mem instr_mem_inst (
    .addr_i(pc),
    .instr_o(instr)
);

pc_reg pc_reg_inst (
    .clk(clk & trigger_latched),
    .rst(rst),
    .pc_next_i(pc_next),

    .pc_o(pc)
);


/// /// BLOCK 2: Register file, control unit, and extend /// ///

// // // control unit signals
// instr signal has been declared in block 1
logic [24:0] instr_31_7 = instr[31:7];
logic [6:0] op = instr[6:0];
logic [2:0] funct3 = instr[14:12];
logic [6:0] funct7 = instr[31:25];
// signal pc_src has been declared in block 1
logic reg_wr_en, mem_wr_en, result_src, alu_src, alu_src_a_sel, signed_bit;
logic [2:0] imm_src;
logic [3:0] alu_control;


// // // Register signals
logic [4:0] rd_addr1 = instr[19:15]; // rd_addr1: instr[19:15]
logic [4:0] rd_addr2 = instr[24:20]; // rd_addr2: instr[24:20]
logic [4:0] wr_addr  = instr[11:7];  // wr_addr: instr[11:7]
logic [DATA_WIDTH-1:0] rd_data1, rd_data2;
logic [DATA_WIDTH-1:0] alu_result;

// // // extend block signal
logic [DATA_WIDTH-1:0] imm_ext;

// Instantiate Control Unit
control_unit ctrl (
    .opcode_i(op),
    .funct3_i(funct3),
    .funct7_i(funct7),
    .zero_i(eq),
    .alu_result_i(alu_result),

    .reg_wr_en_o(reg_wr_en),
    .mem_wr_en_o(mem_wr_en),
    .imm_src_o(imm_src),
    .alu_src_o(alu_src),  
    .result_src_o(result_src),  
    .alu_control_o(alu_control),
    .pc_src_o(pc_src),
    .byte_en_o(mem_byte_en),
    .alu_src_a_sel_o(alu_src_a_sel),
    .signed_o(signed_bit)
);

// Instantiate Sign-Extension Unit
sign_exten sign_exten_inst (
    .instr_31_7_i(instr_31_7),
    .imm_src_i(imm_src),
    .signed_i(signed_bit),

    .imm_ext_o(imm_ext)
);

register_file reg_file_inst (
    .clk(clk),
    .rd_addr1_i(rd_addr1),
    .rd_addr2_i(rd_addr2),
    .wr_addr_i(wr_addr),
    .wr_data_i(result),
    .reg_wr_en_i(reg_wr_en),

    .rd_data1_o(rd_data1),
    .rd_data2_o(rd_data2),
    .a0(a0)
);

/// /// BLOCK 3: Control Unit, the Sign-extension Unit and the instruction memory  /// ///
// pc_target has been declared in block 1
// // ALU signals
logic [DATA_WIDTH-1:0] src_a, src_b;
logic eq; // zero flag
logic [3:0] mem_byte_en;

// // data memory siganls 
logic [DATA_WIDTH-1:0] read_data;

// ALU unit
alu alu_inst(
    .src_a_i(src_a),
    .src_b_i(src_b),
    .alu_control_i(alu_control),

    .alu_result_o(alu_result),
    .zero_o(eq)
);

logic [DATA_WIDTH-1:0] option;

always_comb begin
    case (op)
        7'b0110111: option = 32'b0; // LUI
        default: option = pc; // AUIPC
    endcase
end

data_mem_sys data_mem_sys_inst(
    .clk(clk),
    .addr_i(alu_result),
    .wr_data_i(rd_data2),
    .wr_en_i(mem_wr_en),
    .byte_en_i(mem_byte_en),

    .rd_data_o(read_data)
);

logic data_mem_or_pc_mem_sel;
logic [31:0] data_to_use;

always_comb begin
    case (op)
        7'b1101111: data_mem_or_pc_mem_sel = 1;
        7'b1100111: data_mem_or_pc_mem_sel = 1;
        default: data_mem_or_pc_mem_sel = 0;
    endcase
end

mux data_mem_pc_next(
    .in0_i(read_data),
    .in1_i(pc_plus_4),
    .sel_i(data_mem_or_pc_mem_sel),

    .out_o(data_to_use)
);

//MUX for src_a (ALU first operand)
mux alu_src_a_mux(
    .in0_i(rd_data1),       // from reg_file (default operand)
    .in1_i(option), // only for LUi and AUIPC
    .sel_i(alu_src_a_sel),  // new control signal for src_a selection

    .out_o(src_a)
);
logic [DATA_WIDTH-1:0] result;

// always_comb begin
//     case (op)
//         7'b0110111: imm = imm_ext << 12; // LUI
//         7'b0010111: imm = imm_ext << 12; // AUIPC
//         default: imm = imm_ext;
//     endcase
// end

// MUX for src_b (ALU second operand)
mux alu_src_b_mux(
    .in0_i(rd_data2),         // From register file
    .in1_i(imm_ext),          // Immediate value
    .sel_i(alu_src),          // ALU source control signal

    .out_o(src_b)
);

// mux used for data memory
mux data_mem_mux(
    .in0_i(alu_result),
    .in1_i(data_to_use),
    .sel_i(result_src),

    .out_o(result) 
);

logic [DATA_WIDTH-1:0] option2;

always_comb begin
    case (op)
        7'b1100111: begin //JAL
            option2 = rd_data1;
        end
        default: option2 = pc; // JALR
    endcase
end

// adder used to add pc and imm_ext
adder alu_adder(
    .in1_i(option2),
    .in2_i(imm_ext),
    
    .out_o(pc_target)
);

endmodule
