module adder (
    input  logic [31:0] in1,     // First input 
    input  logic [31:0] in2,     // Second input

    output logic [31:0] out      // Result of addition
);

    assign out = in1 + in2;

endmodule
