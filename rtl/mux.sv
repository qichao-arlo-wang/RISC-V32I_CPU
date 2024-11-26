module mux #(
    DATA_WIDTH = 32
) (
    input   logic [DATA_WIDTH-1:0]  in0_i,
    input   logic [DATA_WIDTH-1:0]  in1_i,
    input   logic                   sel_i,
    output  logic [DATA_WIDTH-1:0]  out_o
);
    assign out_o = sel_i ? in1_i : in0_i;

endmodule
