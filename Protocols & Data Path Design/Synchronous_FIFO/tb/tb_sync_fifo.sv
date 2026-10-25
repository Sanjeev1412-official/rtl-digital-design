`timescale 1ns/1ps

module tb_sync_fifo;

    localparam int DATA_WIDTH          = 8;
    localparam int DEPTH               = 16;
    localparam int ALMOST_FULL_THRESH  = DEPTH - 2; // 14
    localparam int ALMOST_EMPTY_THRESH = 2;

    logic                  clk = 0;
    always #10 clk = ~clk; // 50 MHz

    logic                  rst_n;
    logic                  wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic                  full;
    logic                  almost_full;
    logic                  overflow;

    logic                  rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic                  empty;
    logic                  almost_empty;
    logic                  underflow;

    logic [$clog2(DEPTH):0] data_cnt;

    int test_errors = 0;

    sync_fifo #(
        .DATA_WIDTH          (DATA_WIDTH),
        .DEPTH               (DEPTH),
        .ALMOST_FULL_THRESH  (ALMOST_FULL_THRESH),
        .ALMOST_EMPTY_THRESH (ALMOST_EMPTY_THRESH)
    ) dut (
        .clk                 (clk),
        .rst_n               (rst_n),
        .wr_en               (wr_en),
        .wr_data             (wr_data),
        .full                (full),
        .almost_full         (almost_full),
        .overflow            (overflow),
        .rd_en               (rd_en),
        .rd_data             (rd_data),
        .empty               (empty),
        .almost_empty        (almost_empty),
        .underflow           (underflow),
        .data_cnt            (data_cnt)
    );

    // -------------------------------------------------------------
    // Helper Tasks
    // -------------------------------------------------------------
    task automatic write_byte(input [DATA_WIDTH-1:0] data);
        @(posedge clk);
        wr_en   <= 1'b1;
        wr_data <= data;
        @(posedge clk);
        wr_en   <= 1'b0;
    endtask

    task automatic read_byte(input [DATA_WIDTH-1:0] expected_data);
        @(posedge clk);
        rd_en <= 1'b1;
        @(posedge clk);
        rd_en <= 1'b0;
        #1; // Allow registered output to settle after posedge clk
        if (rd_data !== expected_data) begin
            $display(">>> ERROR: Data mismatch! Got 0x%02h, Expected 0x%02h", rd_data, expected_data);
            test_errors++;
        end else begin
            $display("    Read: 0x%02h (Expected: 0x%02h) [OK]", rd_data, expected_data);
        end
    endtask

    // -------------------------------------------------------------
    // Test Sequencer
    // -------------------------------------------------------------
    initial begin
        $dumpfile("Protocols & Data Path Design/Synchronous_FIFO/wave/sync_fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        rst_n   = 1'b0;
        wr_en   = 1'b0;
        wr_data = '0;
        rd_en   = 1'b0;

        #100;
        @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        $display("==========================================================");
        $display("      STARTING SYNCHRONOUS FIFO VERIFICATION");
        $display("==========================================================");

        // TEST 1: Initial Reset Status Check
        $display("\n--- TEST 1: Check Reset State ---");
        if (!empty || full || data_cnt !== 0 || !almost_empty) begin
            $display(">>> ERROR: Reset state incorrect! empty=%b, full=%b, cnt=%0d", empty, full, data_cnt);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Initial reset state verified (empty=1, full=0, cnt=0).");
        end

        // TEST 2: Underflow Detection
        $display("\n--- TEST 2: Underflow Test (Read while Empty) ---");
        @(posedge clk);
        rd_en <= 1'b1;
        @(posedge clk);
        rd_en <= 1'b0;
        @(posedge clk);
        if (!underflow) begin
            $display(">>> ERROR: Expected underflow assertion, but underflow=%b", underflow);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Underflow correctly flagged!");
        end

        // TEST 3: Fill FIFO to Capacity (16 items)
        $display("\n--- TEST 3: Sequential Fill to FULL ---");
        for (int i = 0; i < DEPTH; i++) begin
            write_byte(8'h10 + i);
            $display("    Pushed: 0x%02h, Current data_cnt = %0d, almost_full = %b", 8'h10 + i, data_cnt, almost_full);
        end

        @(posedge clk);
        if (!full || empty || data_cnt !== DEPTH) begin
            $display(">>> ERROR: Full state failed! full=%b, empty=%b, cnt=%0d", full, empty, data_cnt);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: FIFO completely filled to DEPTH = 16 (full=1).");
        end

        // TEST 4: Overflow Detection
        $display("\n--- TEST 4: Overflow Test (Write while Full) ---");
        write_byte(8'hEE);
        @(posedge clk);
        if (!overflow) begin
            $display(">>> ERROR: Expected overflow assertion, but overflow=%b", overflow);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Overflow correctly flagged!");
        end

        // TEST 5: Drain FIFO to Empty (16 items)
        $display("\n--- TEST 5: Sequential Drain to EMPTY ---");
        for (int i = 0; i < DEPTH; i++) begin
            read_byte(8'h10 + i);
        end

        @(posedge clk);
        if (!empty || full || data_cnt !== 0) begin
            $display(">>> ERROR: Empty state failed! empty=%b, full=%b, cnt=%0d", empty, full, data_cnt);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: FIFO drained cleanly in exact FIFO order (empty=1).");
        end

        // TEST 6: Simultaneous Read and Write
        $display("\n--- TEST 6: Simultaneous Read & Write Streaming ---");
        // Pre-fill 4 words
        for (int i = 0; i < 4; i++) write_byte(8'hA0 + i);

        // Stream 4 writes and 4 reads simultaneously
        for (int i = 0; i < 4; i++) begin
            @(posedge clk);
            wr_en   <= 1'b1;
            wr_data <= 8'hB0 + i;
            rd_en   <= 1'b1;
            @(posedge clk);
            wr_en   <= 1'b0;
            rd_en   <= 1'b0;
            $display("    Simultaneous WR (0x%02h) & RD (0x%02h), data_cnt = %0d", 8'hB0 + i, rd_data, data_cnt);
        end

        // Drain remaining
        while (!empty) begin
            @(posedge clk);
            rd_en <= 1'b1;
            @(posedge clk);
            rd_en <= 1'b0;
        end

        // TEST 7: Full Capacity Simultaneous Read & Write Handshake
        $display("\n--- TEST 7: Simultaneous Read & Write while FULL ---");
        for (int i = 0; i < DEPTH; i++) write_byte(8'hC0 + i);
        @(posedge clk);

        // While full, assert both wr_en and rd_en
        @(posedge clk);
        wr_en   <= 1'b1;
        wr_data <= 8'hD0;
        rd_en   <= 1'b1;
        @(posedge clk);
        wr_en   <= 1'b0;
        rd_en   <= 1'b0;
        @(posedge clk);

        if (overflow) begin
            $display(">>> ERROR: Simultaneous RW while full erroneously flagged overflow!");
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Simultaneous RW while full operated seamlessly without overflow!");
        end

        // Final Summary
        #100;
        $display("\n==========================================================");
        if (test_errors == 0) begin
            $display("   ALL FIFO TESTS PASSED SUCCESSFULLY! (0 ERRORS)");
        end else begin
            $display("   FIFO VERIFICATION FAILED WITH %0d ERRORS!", test_errors);
        end
        $display("==========================================================\n");

        $finish;
    end

endmodule
