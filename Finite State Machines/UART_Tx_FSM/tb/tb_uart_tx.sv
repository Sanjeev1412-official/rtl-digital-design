`timescale 1ns/1ps

module tb_uart_tx;
	// NOTE: This UART TX design sends 1 bit per clock:
	// START (1 clk) -> DATA[0:7] LSB-first (8 clks) -> STOP (1 clk, tx_done=1)

	logic clk;
	logic rst;
	logic tx_start;
	logic [7:0] data_in;
	logic tx;
	logic tx_done;

	int unsigned error_count;

	// DUT
	uart_tx dut (
		.clk      (clk),
		.rst      (rst),
		.tx_start (tx_start),
		.data_in  (data_in),
		.tx       (tx),
		.tx_done  (tx_done)
	);

	// 100 MHz clock (10 ns period)
	initial clk = 1'b0;
	always #5 clk = ~clk;

	// Small helper: sample after state/output settles
	task automatic sample_settled;
		#1;
	endtask

	task automatic expect_bit(
		input string what,
		input logic  exp_tx,
		input logic  exp_done
	);
		if (tx !== exp_tx || tx_done !== exp_done) begin
			error_count++;
			$display("[%0t] ERROR %-10s  tx=%0b (exp %0b)  tx_done=%0b (exp %0b)",
							 $time, what, tx, exp_tx, tx_done, exp_done);
		end else begin
			$display("[%0t] OK    %-10s  tx=%0b  tx_done=%0b", $time, what, tx, tx_done);
		end
	endtask

	task automatic send_byte_and_check(input logic [7:0] b);
		int i;
		$display("\n[%0t] ---- TRANSMIT 0x%02h (%0d) ----", $time, b, b);

		// Ensure we're in idle-like condition
		@(negedge clk);
		tx_start = 1'b0;
		data_in  = b;

		// A couple of idle cycles (tx should be high, tx_done low)
		repeat (2) begin
			@(posedge clk); sample_settled();
			expect_bit("IDLE", 1'b1, 1'b0);
		end

		// Launch: assert tx_start for exactly 1 clock
		@(negedge clk);
		data_in  = b;
		tx_start = 1'b1;

		// START bit appears immediately after this posedge
		@(posedge clk); sample_settled();
		expect_bit("START", 1'b0, 1'b0);

		// Deassert start
		@(negedge clk);
		tx_start = 1'b0;

		// DATA bits
		for (i = 0; i < 8; i++) begin
			@(posedge clk); sample_settled();
			if (tx !== b[i]) begin
				error_count++;
				$display("[%0t] ERROR DATA[%0d]    tx=%0b (exp %0b)", $time, i, tx, b[i]);
			end else begin
				$display("[%0t] OK    DATA[%0d]    tx=%0b", $time, i, tx);
			end
			if (tx_done !== 1'b0) begin
				error_count++;
				$display("[%0t] ERROR DATA[%0d]    tx_done=%0b (exp 0)", $time, i, tx_done);
			end
		end

		// STOP bit + done pulse
		@(posedge clk); sample_settled();
		expect_bit("STOP", 1'b1, 1'b1);

		// Back to IDLE
		@(posedge clk); sample_settled();
		expect_bit("IDLE", 1'b1, 1'b0);
	endtask

	initial begin
		error_count = 0;
		rst      = 1'b1;
		tx_start = 1'b0;
		data_in  = 8'h00;

		$timeformat(-9, 0, " ns", 10);
		$dumpfile("tb_uart_tx.vcd");
		$dumpvars(0, tb_uart_tx);

		// Reset for a few cycles
		repeat (3) @(posedge clk);
		rst = 1'b0;
		$display("[%0t] Reset deasserted", $time);

		// Basic frames
		send_byte_and_check(8'hA5); // 1010_0101
		send_byte_and_check(8'h3C); // 0011_1100
		send_byte_and_check(8'h00);
		send_byte_and_check(8'hFF);

		$display("\n[%0t] Simulation finished. Errors: %0d", $time, error_count);
		if (error_count == 0) $display("PASS");
		else                  $display("FAIL");

		#20;
		$finish;
	end

endmodule

