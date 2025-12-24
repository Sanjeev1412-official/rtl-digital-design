`timescale 1ns/1ps

module mux_2to1_case_tb;
    reg a;
    reg b;
    reg selection;
    wire y;
    
    mux_2to1_case dut(
        .a         	(a          ),
        .b         	(b          ),
        .selection 	(selection  ),
        .y         	(y          )
    );

    initial begin
        $dumpfile("wave/mux_2to1.vcd");
        $dumpvars(0, mux_2to1_case_tb);

        // Test case 1
        $display("Test case 1: selection = 0");
        a = 0; b= 0; selection = 0; #10;
        $display("00: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 0; b= 1; selection = 0; #10;
        $display("01: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 1; b= 0; selection = 0; #10;
        $display("10: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 1; b= 1; selection = 0; #10;
        $display("11: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);

        // Test case 2
        $display("Test case 2: selection = 1");
        a = 0; b= 0; selection = 1; #10;
        $display("00: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 0; b= 1; selection = 1; #10;
        $display("01: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 1; b= 0; selection = 1; #10;
        $display("10: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);
        a = 1; b= 1; selection = 1; #10;
        $display("11: a=%b, b=%b, selection=%b => y=%b", a, b, selection, y);

        $finish;
    end


endmodule