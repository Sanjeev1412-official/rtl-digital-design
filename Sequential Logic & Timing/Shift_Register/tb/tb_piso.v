//testbench for PISO Shift Register
`timescale 1ns / 1ps

module tb_piso;
    parameter N = 4;
    reg clk;
    reg rst;
    reg load;
    reg [N-1:0] parallel_in;
    wire serial_out;

    piso #(.N(N)) dut(
        .clk(clk),
        .rst(rst),
        .load(load),
        .parallel_in(parallel_in),
        .serial_out(serial_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("Time: %0t | rst: %b | load: %b | parallel_in: %b | shift_reg: %b | serial_out: %b",
                 $time, rst, load, parallel_in, dut.shift_reg, serial_out);
    end

    initial begin
        $dumpfile("Shift_Register/wave/piso.vcd");
        $dumpvars(0, tb_piso);

        // Initialize
        rst = 1;
        load = 0;
        parallel_in = 0;

        repeat (2) @(negedge clk);
        rst = 0;

        load = 1; parallel_in = 4'b1010; @(negedge clk);

        load = 0;
        repeat (4) @(negedge clk);

        $finish;

    end
endmodule