//parameterized n-bit adder in verilog

`timescale 1ns/1ps
module n_bit_adder #(
    parameter N = 8   // default bit width
)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    input wire cin,
    output wire [N-1:0] sum,
    output wire cout
);

wire [N:0] temp;
assign temp = a + b + cin;

assign sum = temp[N-1:0];
assign cout = temp[N];

endmodule