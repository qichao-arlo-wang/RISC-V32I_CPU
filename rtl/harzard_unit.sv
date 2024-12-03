module hazard_unit (
    // extra signal used to detect lw for stall
    input logic [4:0] rd_addr1_d_i,
    input logic [4:0] rd_addr2_d_i,
    input logic [4:0] wr_addr_e_i, // RdE
    input logic mem_byte_en_e_i,
    
    // data 
    input logic [4:0] rd_addr1_e_i, // Rs1E
    input logic [4:0] rd_addr2_e_i, // Rs2E
    input logic [4:0] wr_addr_m_i, // RdM
    input logic [4:0] wr_addr_w_i, // RdW
    input logic reg_wr_en_m_i,
    input logic reg_wr_en_w_i,
    input logic pc_src_i, // the original pc_src, not in those registers for pipeline

    output logic [1:0] forward_a_e_o,
    output logic [1:0] forward_b_e_o,
    output logic stall_o,
    output logic flush_o

);

    always_comb begin

        stall_o = 1'b0;
        flush_o = 1'b0;
        forward_a_e_o = 2'b00;
        forward_b_e_o = 2'b00;

        // MUX for forward_a_e_o
            // 00 : rd_addr1_e : same as no pipeline
            // 01 : result_w : forwarding from W state after a MUX in lecture slides(after data memory)
            // 10 : alu_result_m : forwarding from M state(after ALU)

        if (reg_wr_en_m_i && (wr_addr_m_i != 0) && (wr_addr_m_i == rd_addr1_e_i)) begin
            forward_a_e_o = 2'b10;
        end 
        else if (reg_wr_en_w_i && (wr_addr_w_i != 0) && (wr_addr_w_i == rd_addr1_e_i)) begin
            forward_a_e_o = 2'b01;
        end 
        else begin
            forward_a_e_o = 2'b00;
        end

        // MUX for forward_b_e_o
            // 00 : rd_addr2_e : same as no pipeline
            // 01 : result_w : forwarding from W state after a MUX in lecture slides(after data memory)
            // 10 : alu_result_m : forwarding from M state(after ALU)

        if (reg_wr_en_m_i && (wr_addr_m_i != 0) && (wr_addr_m_i == rd_addr2_e_i)) begin
            forward_b_e_o = 2'b10;
        end 
        else if (reg_wr_en_w_i && (wr_addr_w_i != 0) && (wr_addr_w_i == rd_addr2_e_i)) begin
            forward_b_e_o = 2'b01;
        end 
        else begin
            forward_b_e_o = 2'b00;
        end


        // Branch happen / Jump instruction  ---> flush
        if (pc_src_i) begin 
            flush_o = 1;
        end

        // Load Instruction --> Stall
        // When both 1: There is Load Instruction in the Execution stage
        //           2: Register used to write at Execution stage Overlapped with one of register are used in Decoding Stage
        
        //mem_ byte_en used for load (3 case depends on bit used)
        if ((((mem_byte_en_e_i == 4'b0001)||(mem_byte_en_e_i == 4'b0011)||(mem_byte_en_e_i == 4'b1111))) && ((wr_addr_e_i == rd_addr1_d_i) || (wr_addr_e_i == rd_addr2_d_i))) begin
            stall_o = 1'b1;
        end
        else begin
            stall_o = 1'b0;
        end


    end
     

endmodule