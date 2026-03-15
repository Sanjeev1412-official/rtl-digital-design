//testbench for SIPO Shift Register
`timescale 1ns / 1ps

module tb_sipo;
    parameter N = 4;
    reg clk;
    reg rst;
    reg serial_in;
    wire [N-1:0] parallel_out;

    sipo #(.N(N)) dut(
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .parallel_out(parallel_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("Time: %0t | rst: %b | serial_in: %b | parallel_out: %b",
                 $time, rst, serial_in, parallel_out);
    end

    initial begin
        $dumpfile("Shift_Register/wave/sipo.vcd");
        $dumpvars(0, tb_sipo);

        // Initialize
        rst = 1;
        serial_in = 0;

        // Avoid race with DUT sampling on posedge: drive inputs on negedge.
        repeat (2) @(negedge clk);
        rst = 0;

        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;
        @(negedge clk); serial_in = 1;
        @(negedge clk); serial_in = 0;

        repeat (N + 2) @(negedge clk);

        $finish;

    end
endmodule