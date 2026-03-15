//testbench for SISO Shift Register
`timescale 1ns / 1ps

module tb_siso;
    parameter N = 4;
    reg clk;
    reg rst;
    reg serial_in;
    wire serial_out;

    siso #(.N(N)) dut(
        .clk(clk),
        .rst(rst),
        .serial_in(serial_in),
        .serial_out(serial_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("Time: %0t | rst: %b | serial_in: %b | shift_reg: %b | serial_out: %b",
                 $time, rst, serial_in, dut.shift_reg, serial_out);
    end

    initial begin
        $dumpfile("Shift_Register/wave/siso.vcd");
        $dumpvars(0, tb_siso);

        // Initialize
        rst = 1;
        serial_in = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        serial_in = 1; @(negedge clk);
        serial_in = 0; @(negedge clk);
        serial_in = 1; @(negedge clk);
        serial_in = 0; @(negedge clk);

        repeat (N + 2) @(negedge clk);

        $finish;

    end
endmodule