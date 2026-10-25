`timescale 1ns/1ps

module tb_baud_rate_gen;

    localparam int CLK_FREQ   = 50_000_000;
    localparam int OVERSAMPLE = 16;

    logic        clk = 0;
    always #10 clk = ~clk; // 50 MHz (20ns period)

    logic        rst_n;
    logic        enable;
    logic [2:0]  baud_sel;
    logic [15:0] custom_div;
    logic        custom_en;
    logic        sample_tick;
    logic        baud_tick;

    int test_errors = 0;

    baud_rate_gen #(
        .CLK_FREQ   (CLK_FREQ),
        .OVERSAMPLE (OVERSAMPLE)
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .enable      (enable),
        .baud_sel    (baud_sel),
        .custom_div  (custom_div),
        .custom_en   (custom_en),
        .sample_tick (sample_tick),
        .baud_tick   (baud_tick)
    );

    // -------------------------------------------------------------
    // Measurement Task
    // -------------------------------------------------------------
    task automatic measure_ticks(
        input string rate_name,
        input int expected_sample_clks,
        input int expected_samples_per_baud
    );
        int clk_count;
        int sample_count;
        time t1, t2;

        $display("\n--- Measuring %s ---", rate_name);
        
        // Wait for first sample_tick to align
        @(posedge sample_tick);
        t1 = $time;
        // Wait for next sample_tick
        @(posedge sample_tick);
        t2 = $time;

        // With 50 MHz and `timescale 1ns/1ps, 1 cycle (20ns) = 20 time units
        clk_count = int'((t2 - t1) / 20);

        $display("    Clocks per sample_tick: %0d (Expected: %0d)", clk_count, expected_sample_clks);
        if (clk_count !== expected_sample_clks) begin
            $display(">>> ERROR: Sample tick period mismatch! (t2=%0t, t1=%0t, diff=%0t)", t2, t1, t2-t1);
            test_errors++;
        end else begin
            $display("    Sample tick period [OK]");
        end

        // Measure sample_ticks per baud_tick
        @(posedge baud_tick);
        @(posedge sample_tick);
        sample_count = 1;
        while (!baud_tick) begin
            @(posedge sample_tick);
            sample_count++;
        end

        $display("    Samples per baud_tick:  %0d (Expected: %0d)", sample_count, expected_samples_per_baud);
        if (sample_count !== expected_samples_per_baud) begin
            $display(">>> ERROR: Oversampling ratio mismatch!");
            test_errors++;
        end else begin
            $display("    Oversampling ratio [OK]");
        end
    endtask

    // -------------------------------------------------------------
    // Test Sequencer
    // -------------------------------------------------------------
    initial begin
        $dumpfile("Protocols & Data Path Design/Baud_Rate_Generator/wave/baud_rate_gen.vcd");
        $dumpvars(0, tb_baud_rate_gen);

        rst_n      = 1'b0;
        enable     = 1'b0;
        baud_sel   = 3'b000;
        custom_div = 16'd0;
        custom_en  = 1'b0;

        #100;
        @(posedge clk);
        rst_n = 1'b1;
        #50;

        $display("==========================================================");
        $display("     STARTING BAUD RATE GENERATOR VERIFICATION");
        $display("==========================================================");

        // TEST 1: Enable Gating
        $display("\n--- TEST 1: Enable Gating (enable = 0) ---");
        repeat (100) @(posedge clk);
        if (sample_tick !== 0 || baud_tick !== 0) begin
            $display(">>> ERROR: Ticks generated while enable was 0!");
            test_errors++;
        end else begin
            $display(">>> SUCCESS: No ticks generated when disabled.");
        end

        enable = 1'b1;

        // TEST 2: Preset 115200 Baud (Divisor = 27)
        baud_sel  = 3'b100; // 115200
        custom_en = 1'b0;
        measure_ticks("Preset 115200 Baud", 27, 16);

        // TEST 3: Preset 921600 Baud (Divisor = 3)
        baud_sel  = 3'b111; // 921600
        measure_ticks("Preset 921600 Baud", 3, 16);

        // TEST 4: Custom Divisor Mode (div = 10 -> 10 clocks per sample, 160 per baud)
        $display("\n--- TEST 4: Custom Divisor Mode ---");
        custom_en  = 1'b1;
        custom_div = 16'd10;
        measure_ticks("Custom Divisor = 10", 10, 16);

        // TEST 5: On-the-fly Dynamic Switching to 57600
        $display("\n--- TEST 5: Dynamic On-the-Fly Switching ---");
        custom_en = 1'b0;
        baud_sel  = 3'b011; // 57600 (Divisor = 54)
        measure_ticks("Dynamic Switch to 57600 Baud", 54, 16);

        // Summary
        #100;
        $display("\n==========================================================");
        if (test_errors == 0) begin
            $display("   ALL BAUD RATE GENERATOR TESTS PASSED! (0 ERRORS)");
        end else begin
            $display("   VERIFICATION FAILED WITH %0d ERRORS!", test_errors);
        end
        $display("==========================================================\n");

        $finish;
    end

endmodule
