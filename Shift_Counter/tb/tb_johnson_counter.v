//testbench johnson counter
`timescale 1ns / 1ps

module tb_johnson_counter;
    parameter N=4;
    reg clk;
    reg rst;
    wire [N-1:0] count;
    
    johnson_counter #(
        .N 	(N ))
    dut(
        .clk   	(clk    ),
        .rst   	(rst    ),
        .count 	(count  )
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("Time: %0t | rst: %b === count: %b",
                 $time, rst, count);
    end

    initial begin
        $dumpfile("Shift_Counter/wave/johnson_counter.vcd");
        $dumpvars(0, tb_johnson_counter);

        // Initialize
        rst=1;
        repeat (2) @(negedge clk);
        rst=0;
        repeat (20) @(negedge clk);

        $finish();
    end

endmodule
    