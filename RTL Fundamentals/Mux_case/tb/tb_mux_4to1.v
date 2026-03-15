`timescale 1ns/1ps

module mux_4to1_case_tb;
    reg a;
    reg b;
    reg c;
    reg d;
    reg [1:0] selection;
    wire y;

    mux_4to1_case dut(
        .a         	(a          ),
        .b         	(b          ),
        .c         	(c          ),
        .d         	(d          ),
        .selection 	(selection  ),
        .y         	(y          )
    );

    initial begin

        $dumpfile("wave/mux_4to1.vcd");
        $dumpvars(0, mux_4to1_case_tb);

        // Test case 1
        $display("Test case 1: 0000");

        a=0;b=0;c=0;d=0;

        selection = 2'b00; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b01; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b10; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b11; #10;
        $display("selection=%b => y=%b", selection, y);

        // Test case 2
        $display("Test case 2: 0101");

        a=0;b=1;c=0;d=1;

        selection = 2'b00; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b01; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b10; #10;
        $display("selection=%b => y=%b", selection, y);
        selection = 2'b11; #10;
        $display("selection=%b => y=%b", selection, y);

        $finish;
    end

endmodule