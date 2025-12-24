//up_down_counter testbench
`timescale 1ns / 1ps

module tb_up_down_counter;

    parameter N = 4;
    reg clk;
    reg rst; 
    reg en;
    reg up_down;
    wire [N-1:0] count;
    
    up_down_counter #(.N(N)) dut(
        .clk     	(clk      ),
        .rst     	(rst      ),
        .en      	(en       ),
        .up_down 	(up_down  ),
        .count   	(count    )
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
            $display("rst=%b , en=%b ,updown=%b",rst,en,up_down);
            $display("count = %b" , count);
        end

    initial begin
        $dumpfile("Up_Down_Counter/wave/up_down_counter.vcd");
        $dumpvars(0,tb_up_down_counter);

        //test
        rst=1; en=0; up_down=1; #5;
        repeat (2) @(posedge clk);
        
        rst=0; en=1; #50; 
        @(posedge clk);

        up_down=0; #50;
        @(posedge clk);

        en=0; #5;
        @(posedge clk);

        $finish;
    end

endmodule
