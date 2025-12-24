// testbench for 8-bit ALU
`timescale 1ns / 1ps

module alu_8bit_tb;

reg [7:0] a;
reg [7:0] b;
reg [1:0] opcode;
wire [7:0] y;
wire carryout, zero;

alu_8bit dut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .y(y),
    .carryout(carryout),
    .zero(zero)
);

initial begin
    $dumpfile("wave/alu.vcd");
    $dumpvars(0, alu_8bit_tb);

    $display("==== Testing 8-bit ALU ====");

    // ADD
    a = 10; b = 20; opcode = 2'b00; #10;
    $display("ADD  a=%0d b=%0d y=%0d carry=%b zero=%b", a, b, y, carryout, zero);

    a = 200; b = 100; opcode = 2'b00; #10;
    $display("ADD  a=%0d b=%0d y=%0d carry=%b zero=%b", a, b, y, carryout, zero);

    // SUB
    a = 50; b = 20; opcode = 2'b01; #10;
    $display("SUB  a=%0d b=%0d y=%0d carry=%b zero=%b", a, b, y, carryout, zero);

    a = 20; b = 50; opcode = 2'b01; #10;
    $display("SUB  a=%0d b=%0d y=%0d carry=%b zero=%b", a, b, y, carryout, zero);

    // AND
    a = 8'b11001100; b = 8'b10101010; opcode = 2'b10; #10;
    $display("AND  a=%b b=%b y=%b zero=%b", a, b, y, zero);

    // OR
    a = 8'b11001100; b = 8'b10101010; opcode = 2'b11; #10;
    $display("OR   a=%b b=%b y=%b zero=%b", a, b, y, zero);

    $display("==== TEST COMPLETE ====");
    $finish;
end

endmodule
