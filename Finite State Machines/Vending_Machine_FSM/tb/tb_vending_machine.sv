// testbench

`timescale 1ns/1ps

module tb_vending_machine;
    reg clk;
    reg rst;

    reg coin_5;
    reg coin_10;

    wire dispense;
    wire change_5;

    bit done;

    vending_machine dut (
        .clk(clk),
        .rst(rst),
        .coin_5(coin_5),
        .coin_10(coin_10),
        .dispense(dispense),
        .change_5(change_5)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!done) begin
            $strobe("Time: %0t | rst: %b | coin_5: %b | coin_10: %b | dispense: %b | change_5: %b",
                    $time, rst, coin_5, coin_10, dispense, change_5);
        end
    end

    initial begin

        $dumpfile("wave/vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);

        // Test sequence
        rst = 1;
        coin_5 = 0;
        coin_10 = 0;
        done = 0;
        #10;
        @(posedge clk);
        rst = 0;
        #10;

        // Insert ₹5
        coin_5 = 1;
        @(posedge clk);
        @(negedge clk);
        coin_5 = 0;
        #10;

        // Insert ₹10
        coin_10 = 1;
        @(posedge clk);
        @(negedge clk);
        coin_10 = 0;
        #10;

        // Insert ₹10
        coin_10 = 1;
        @(posedge clk);
        @(negedge clk);
        coin_10 = 0;
        #10;


        // Insert ₹10
        coin_10 = 1;
        @(posedge clk);
        @(negedge clk);
        coin_10 = 0;
        #10;

        // Stop logging before the last clock edge to avoid an extra print
        done = 1;
        @(posedge clk);
        $finish;
    end
endmodule