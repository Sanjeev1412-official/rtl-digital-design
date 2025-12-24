//testbench

`timescale 1ns/1ps

module tb_clock_divider;

parameter N = 4;

reg clk_in;
reg rst;
wire clk_out;


clock_divider #(
    .N 	(N))
dut(
    .clk_in  	(clk_in   ),
    .rst     	(rst      ),
    .clk_out 	(clk_out  )
);

initial clk_in = 0;
always #10 clk_in = ~clk_in;

always @(posedge clk_in) begin
    $display("clk=%b | rst=%b === clk_out=%b", clk_in, rst,clk_out);
end

initial begin
    $dumpfile("Clock_Divider/wave/clock_divider.vcd");
    $dumpvars(0,tb_clock_divider );

    rst = 1; 
    #20
    repeat(2) @(posedge clk_in);

    rst = 0;

    #200
    @(posedge clk_in);

    $finish;
end
endmodule