`timescale 1ns/1ps

module tb_comp_1bit;

    reg a;
    reg b;  
    wire gt;
    wire lt;
    wire eq;

    comp_1bit_case u_comp_1bit_case(
        .a  	(a   ),
        .b  	(b   ),
        .gt 	(gt  ),
        .lt 	(lt  ),
        .eq 	(eq  )
    );

    initial begin
        $dumpfile("wave/comp_1bit.vcd");
        $dumpvars(0, tb_comp_1bit);

        $display("a b | gt lt eq");
        a=0; b=0; #10;
        $display("%d %d | %d %d %d", a, b, gt, lt, eq);
        a=0; b=1; #10;  
        $display("%d %d | %d %d %d", a, b, gt, lt, eq);    
        a=1; b=0; #10;
        $display("%d %d | %d %d %d", a, b, gt, lt, eq);
        a=1; b=1; #10;
        $display("%d %d | %d %d %d", a, b, gt, lt, eq);

        $finish;
    end
    
endmodule