//testbench for traffic light fsm

`timescale 1ns/1ps

module tb_traffic_light_fsm;
    parameter GREEN_TIME = 5;
    parameter YELLOW_TIME = 2;

    reg clk;
    reg rst;

    wire ns_red, ns_yellow, ns_green;
    wire ew_red, ew_yellow, ew_green;

    traffic_light_fsm #(
        .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME)
    ) dut (
        .clk(clk),
        .rst(rst),
        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),
        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        $strobe("Time: %0t | rst: %b | NS: R=%b Y=%b G=%b | EW: R=%b Y=%b G=%b",
                $time, rst,
                ns_red, ns_yellow, ns_green,
                ew_red, ew_yellow, ew_green);
    end

    initial begin

        $dumpfile("wave/traffic_light_fsm.vcd");
        $dumpvars(0, tb_traffic_light_fsm);

        // Test sequence
        rst = 1;
        #10;
        repeat (2) @(posedge clk);
        rst = 0;
        #200;
        @(posedge clk);

        $finish;
    end



endmodule