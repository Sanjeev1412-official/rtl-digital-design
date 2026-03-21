`timescale 1ns/1ps

module uart_tb;

    logic clk = 0;
    always #10 clk = ~clk;

    logic rst;
    logic start;
    logic [7:0] tx_data;
    logic tx;
    logic rx;
    logic [7:0] rx_data;
    logic valid;
    logic busy;

    int unsigned txn;
    time t_start;

    uart_top dut(.*);

    assign rx = tx;

    // -----------------------------
    // Beginner-friendly event logs
    // -----------------------------
    always @(posedge rst)  $display("[%0t] TB: rst asserted (reset=1)", $time);
    always @(negedge rst)  $display("[%0t] TB: rst deasserted (reset=0)", $time);
    always @(posedge start) $display("[%0t] TB: start=1 (request TX of 0x%02h)", $time, tx_data);
    always @(posedge busy)  $display("[%0t] TB: busy=1 (TX is running)", $time);
    always @(negedge busy)  $display("[%0t] TB: busy=0 (TX is idle)", $time);
    always @(posedge valid) $display("[%0t] TB: valid=1 (RX done). rx_data=0x%02h", $time, rx_data);

    task send_byte(input [7:0] data);
        wait(busy == 0);
        @(posedge clk);
        tx_data = data;
        start = 1;
        @(posedge clk);
        start = 0;
    endtask

    task wait_valid;
        fork
            @(posedge valid);
            begin
                #2ms;
                $fatal(1, "[%0t] TB: TIMEOUT: VALID not asserted", $time);
            end
        join_any
        disable fork;
    endtask

    initial begin
        txn = 0;
        start = 0;
        tx_data = '0;

        $dumpfile("uart_tx_rx.vcd");
        $dumpvars(0, uart_tb);

        $display("[%0t] TB: Simulation start", $time);
        $display("[%0t] TB: clk period = 20ns (50MHz)", $time);

        rst = 1;
        repeat(10) @(posedge clk);
        rst = 0;

        repeat(50) @(posedge clk);

        repeat (10) begin
            txn++;
            tx_data = $urandom;

            $display("\n[%0t] TB: --- Transaction %0d ---", $time, txn);
            $display("[%0t] TB: Send byte tx_data=0x%02h (bin=%08b dec=%0d)", $time, tx_data, tx_data, tx_data);

            t_start = $time;
            send_byte(tx_data);

            $display("[%0t] TB: Waiting for valid...", $time);
            wait_valid();
            $display("[%0t] TB: valid received after %0t", $time, ($time - t_start));

            if (rx_data !== tx_data)
                $error("[%0t] TB: FAIL: sent=0x%02h received=0x%02h", $time, tx_data, rx_data);
            else
                $display("[%0t] TB: PASS: 0x%02h", $time, tx_data);

            repeat(2000) @(posedge clk);
        end

        $finish;
    end
endmodule