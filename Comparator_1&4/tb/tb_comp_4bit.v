`timescale 1ns/1ps

module tb_comp_1bit;

  // Inputs
  reg [3:0] a;
  reg [3:0] b;

  // Outputs
  wire gt;
  wire lt;
  wire eq;

  // Instantiate the Unit Under Test (UUT)
  comp_4bit uut (
    .a(a), 
    .b(b), 
    .gt(gt), 
    .lt(lt), 
    .eq(eq)
  );

  initial begin

    $dumpfile("wave/comp_4bit.vcd");
    $dumpvars(0, tb_comp_1bit);
    
    // Test
    $display("a b | gt lt eq");
    a=4'd10; b=4'd5; #10; 
    $display("%d %d | %d %d %d", a, b, gt, lt, eq);
    a=4'd3;  b=4'd7; #10;   
    $display("%d %d | %d %d %d", a, b, gt, lt, eq);
    a=4'd12; b=4'd12; #10;  
    $display("%d %d | %d %d %d", a, b, gt, lt, eq);
    a=4'd0;  b=4'd0; #10;   
    $display("%d %d | %d %d %d", a, b, gt, lt, eq);
    a=4'd15; b=4'd14; #10;  
    $display("%d %d | %d %d %d", a, b, gt, lt, eq);
    a=4'd8;  b=4'd9; #10;  
    $display("%d %d | %d %d %d", a, b, gt, lt, eq); 

    // Finish simulation
    $finish;
  end

endmodule