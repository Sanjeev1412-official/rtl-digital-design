//testbench

`timescale 1ns / 1ps
module tb_bin_to_gray_4bit;

    reg [3:0] bin;
    wire [3:0] gray;
    
    bin_to_gray_4bit dut(
        .bin  	(bin   ),
        .gray 	(gray  )
    );

    initial begin
        $dumpfile("wave/bin_to_gray_4bit.vcd");
        $dumpvars(0, tb_bin_to_gray_4bit);

        //test
        $display("Binary to Gray 4-bit");
        bin = 4'b0000; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0001; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0010; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0011; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0100; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0101; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0110; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b0111; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1000; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1001; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1010; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1011; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1100; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1101; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1110; #10;
        $display("%b = %b" , bin , gray);
        bin = 4'b1111; #10;
        $display("%b = %b" , bin , gray);

        $finish;
    end
    
endmodule