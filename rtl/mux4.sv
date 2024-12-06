module mux4 #(
    DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  in0_i,
    input   logic [DATA_WIDTH-1:0]  in1_i,
    input   logic [DATA_WIDTH-1:0]  in2_i,
    input   logic [DATA_WIDTH-1:0]  in3_i,
    input   logic [1:0]             sel_i,
    output  logic [DATA_WIDTH-1:0]  out_o
);
    always_comb begin
        case (sel_i)
            2'd0: assign out_o = in0_i;
            2'd1: assign out_o = in1_i;
            2'd2: assign out_o = in2_i;
            2'd3: assign out_o = in3_i;
        endcase
    end

endmodule
