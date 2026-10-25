`timescale 1ns/1ps

module tb_spi_master;

    localparam int DATA_WIDTH = 8;

    logic                  clk = 0;
    always #10 clk = ~clk; // 50 MHz (20ns period)

    logic                  rst_n;
    logic                  start;
    logic                  cpol;
    logic                  cpha;
    logic [7:0]            clk_div;
    logic [DATA_WIDTH-1:0] tx_data;
    logic [DATA_WIDTH-1:0] rx_data;
    logic                  busy;
    logic                  done;

    logic                  sclk;
    logic                  mosi;
    logic                  miso;
    logic                  cs_n;

    int test_errors = 0;

    spi_master #(
        .DATA_WIDTH (DATA_WIDTH)
    ) dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .start   (start),
        .cpol    (cpol),
        .cpha    (cpha),
        .clk_div (clk_div),
        .tx_data (tx_data),
        .rx_data (rx_data),
        .busy    (busy),
        .done    (done),
        .sclk    (sclk),
        .mosi    (mosi),
        .miso    (miso),
        .cs_n    (cs_n)
    );

    // SPI Slave model: Transmits 8'h5A and receives MOSI
    logic [DATA_WIDTH-1:0] slave_tx_reg;
    logic [DATA_WIDTH-1:0] slave_rx_reg;
    logic [DATA_WIDTH-1:0] slave_captured;

    assign miso = slave_tx_reg[DATA_WIDTH-1];

    always @(cs_n) begin
        if (cs_n) begin
            slave_captured <= slave_rx_reg;
            slave_tx_reg   <= 8'h5A;
            slave_rx_reg   <= '0;
        end
    end

    // Slave sampling logic on posedge SCLK
    always_ff @(posedge sclk) begin
        if (!cs_n) begin
            // Mode 0 & Mode 3 sample on posedge SCLK
            if ((!cpol && !cpha) || (cpol && cpha)) begin
                slave_rx_reg <= {slave_rx_reg[DATA_WIDTH-2:0], mosi};
                $display("      [SLAVE POS] time=%0t mosi=%b, new_rx=%b", $time, mosi, {slave_rx_reg[DATA_WIDTH-2:0], mosi});
            end
            // Mode 1 & Mode 2 shift on posedge SCLK
            if ((!cpol && cpha) || (cpol && !cpha)) begin
                slave_tx_reg <= {slave_tx_reg[DATA_WIDTH-2:0], 1'b0};
            end
        end
    end

    // Slave shifting logic on negedge SCLK
    always_ff @(negedge sclk) begin
        if (!cs_n) begin
            // Mode 1 & Mode 2 sample on negedge SCLK
            if ((!cpol && cpha) || (cpol && !cpha)) begin
                slave_rx_reg <= {slave_rx_reg[DATA_WIDTH-2:0], mosi};
            end
            // Mode 0 & Mode 3 shift on negedge SCLK
            if ((!cpol && !cpha) || (cpol && cpha)) begin
                slave_tx_reg <= {slave_tx_reg[DATA_WIDTH-2:0], 1'b0};
            end
        end
    end

    task automatic run_spi_test(
        input logic            mode_cpol,
        input logic            mode_cpha,
        input [7:0]            div,
        input [DATA_WIDTH-1:0] data_to_send,
        input [DATA_WIDTH-1:0] expected_rx
    );
        int mode_num;
        mode_num = {mode_cpol, mode_cpha};

        $display("\n--- Testing SPI Mode %0d (CPOL=%b, CPHA=%b) ---", mode_num, mode_cpol, mode_cpha);
        wait(!busy);
        @(posedge clk);
        cpol    = mode_cpol;
        cpha    = mode_cpha;
        clk_div = div;
        tx_data = data_to_send;
        start   = 1'b1;
        @(posedge clk);
        start   = 1'b0;

        @(posedge done);
        @(posedge clk);
        #1;

        $display("    Master Sent: 0x%02h, Slave Captured: 0x%02h", data_to_send, slave_captured);
        $display("    Master Received: 0x%02h (Expected: 0x%02h)", rx_data, expected_rx);

        if (slave_captured !== data_to_send || rx_data !== expected_rx) begin
            $display(">>> ERROR: Data mismatch in Mode %0d!", mode_num);
            test_errors++;
        end else begin
            $display("    Mode %0d Transaction Verified [OK]", mode_num);
        end
    endtask

    initial begin
        $dumpfile("Protocols & Data Path Design/SPI_Master_Controller/wave/spi_master.vcd");
        $dumpvars(0, tb_spi_master);

        rst_n   = 1'b0;
        start   = 1'b0;
        cpol    = 1'b0;
        cpha    = 1'b0;
        clk_div = 8'd2; // Fast simulation: 2 clocks per half-edge
        tx_data = '0;

        #100;
        @(posedge clk);
        rst_n = 1'b1;
        #50;

        $display("==========================================================");
        $display("       STARTING SPI MASTER CONTROLLER VERIFICATION");
        $display("==========================================================");

        // Test all 4 standard SPI modes
        run_spi_test(1'b0, 1'b0, 8'd2, 8'hA5, 8'h5A); // Mode 0
        run_spi_test(1'b0, 1'b1, 8'd2, 8'h3C, 8'hb4); // Mode 1
        run_spi_test(1'b1, 1'b0, 8'd2, 8'hF0, 8'h5A); // Mode 2
        run_spi_test(1'b1, 1'b1, 8'd2, 8'h5A, 8'hb4); // Mode 3

        #100;
        $display("\n==========================================================");
        if (test_errors == 0) begin
            $display("   ALL SPI 4-MODE TESTS PASSED SUCCESSFULLY! (0 ERRORS)");
        end else begin
            $display("   SPI VERIFICATION FAILED WITH %0d ERRORS!", test_errors);
        end
        $display("==========================================================\n");

        $finish;
    end

endmodule
