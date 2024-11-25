module adder (
    input  logic [31:0] in1_i,     // First input 
    input  logic [31:0] in2_i,     // Second input

    output logic [31:0] out_o      // Result of addition
);

    assign out_o = in1_i + in2_i;

endmodule
