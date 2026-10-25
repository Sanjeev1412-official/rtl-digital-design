`timescale 1ns/1ps


module tb_i2c_master;

    localparam int CLK_FREQ = 50_000_000; 
    localparam int I2C_FREQ = 1_000_000;  

    logic clk = 0;
    always #10 clk = ~clk; 

    logic       rst_n;
    logic       start;
    logic       rw;
    logic [6:0] addr;
    logic [7:0] tx_data;
    logic [7:0] rx_data;
    logic       busy;
    logic       done;
    logic       ack_error;

    wire scl;
    wire sda;

    pullup(scl);
    pullup(sda);


    i2c_master #(
        .CLK_FREQ (CLK_FREQ),
        .I2C_FREQ (I2C_FREQ)
    ) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .rw        (rw),
        .addr      (addr),
        .tx_data   (tx_data),
        .rx_data   (rx_data),
        .busy      (busy),
        .done      (done),
        .ack_error (ack_error),
        .scl       (scl),
        .sda       (sda)
    );

    localparam logic [6:0] SLAVE_ADDR = 7'h50;

    logic       slave_sda_oen = 1'b0; // 1: pull low, 0: release
    assign sda = (slave_sda_oen) ? 1'b0 : 1'bz;

    logic [7:0] slave_reg = 8'h00; // Internal register storage
    logic [7:0] slave_rx_byte;
    logic [7:0] slave_tx_byte;
    logic [6:0] slave_rx_addr;
    logic       slave_rw;
    int         test_errors = 0;

   
    initial begin
        forever begin
            slave_sda_oen = 1'b0;

            
            @(negedge sda);
            if (scl === 1'b1) begin
                
                for (int i = 6; i >= 0; i--) begin
                    @(posedge scl);
                    slave_rx_addr[i] = sda;
                end
                @(posedge scl);
                slave_rw = sda;

                
                @(negedge scl);
                if (slave_rx_addr == SLAVE_ADDR) begin
                    slave_sda_oen = 1'b1; 
                    @(negedge scl);
                    slave_sda_oen = 1'b0; 

                    if (slave_rw == 1'b0) begin
                       
                        for (int i = 7; i >= 0; i--) begin
                            @(posedge scl);
                            slave_rx_byte[i] = sda;
                        end
                       
                        @(negedge scl);
                        slave_sda_oen = 1'b1; 
                        slave_reg = slave_rx_byte;
                        @(negedge scl);
                        slave_sda_oen = 1'b0; 
                    end else begin
                        
                        slave_tx_byte = slave_reg;
                        for (int i = 7; i >= 0; i--) begin
                            slave_sda_oen = ~slave_tx_byte[i];
                            @(negedge scl);
                        end
                    
                        slave_sda_oen = 1'b0;
                        @(negedge scl);
                    end
                end else begin
                    
                    slave_sda_oen = 1'b0;
                end
            end
        end
    end

   
    task automatic i2c_write(input [6:0] dev_addr, input [7:0] data);
        $display("\n[%0t] === TEST: Master WRITE to Addr 0x%02h with Data 0x%02h ===", $time, dev_addr, data);
        wait(!busy);
        @(posedge clk);
        addr    = dev_addr;
        rw      = 1'b0; // Write
        tx_data = data;
        start   = 1'b1;
        @(posedge clk);
        start   = 1'b0;

        @(posedge done);
        @(posedge clk);
        if (ack_error) begin
            $display("[%0t] [RESULT] Master reported ACK Error (NACK)", $time);
        end else begin
            $display("[%0t] [RESULT] Master Write Completed with ACK", $time);
        end
    endtask

    task automatic i2c_read(input [6:0] dev_addr, input [7:0] expected_data);
        $display("\n[%0t] === TEST: Master READ from Addr 0x%02h ===", $time, dev_addr);
        wait(!busy);
        @(posedge clk);
        addr  = dev_addr;
        rw    = 1'b1; // Read
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        @(posedge done);
        @(posedge clk);
        if (ack_error) begin
            $display("[%0t] [RESULT] Master reported ACK Error (NACK)", $time);
        end else begin
            $display("[%0t] [RESULT] Master Read: 0x%02h (Expected: 0x%02h)", $time, rx_data, expected_data);
            if (rx_data !== expected_data) begin
                $display(">>> ERROR: Data mismatch! Got 0x%02h, Expected 0x%02h", rx_data, expected_data);
                test_errors++;
            end else begin
                $display(">>> SUCCESS: Read data matched successfully!");
            end
        end
    endtask

   
    initial begin
        
        $dumpfile("Protocols & Data Path Design/I2C_Master_Controller/wave/i2c_master.vcd");
        $dumpvars(0, tb_i2c_master);

        // Reset
        rst_n   = 1'b0;
        start   = 1'b0;
        rw      = 1'b0;
        addr    = '0;
        tx_data = '0;

        #100;
        @(posedge clk);
        rst_n = 1'b1;
        #100;

        $display("==========================================================");
        $display("   STARTING I2C MASTER CONTROLLER VERIFICATION");
        $display("==========================================================");

        i2c_write(7'h50, 8'h3C);
        #500;
        if (slave_reg !== 8'h3C || ack_error !== 1'b0) begin
            $display(">>> ERROR: Test 1 failed! Slave reg: 0x%02h, ack_error: %b", slave_reg, ack_error);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Slave successfully stored 0x3C in memory!");
        end

        i2c_read(7'h50, 8'h3C);
        #500;

        $display("\n[%0t] === TEST: Access Non-Existent Slave 0x2A (Expect NACK) ===", $time);
        i2c_write(7'h2A, 8'hFF);
        #500;
        if (ack_error !== 1'b1) begin
            $display(">>> ERROR: Expected ack_error = 1 for unmapped slave 0x2A, but got %b", ack_error);
            test_errors++;
        end else begin
            $display(">>> SUCCESS: Master correctly caught NACK (ack_error = 1)!");
        end

        // Summary
        #500;
        $display("\n==========================================================");
        if (test_errors == 0) begin
            $display("   ALL I2C VERIFICATION TESTS PASSED SUCCESSFULLY! (0 ERRORS)");
        end else begin
            $display("   VERIFICATION FAILED WITH %0d ERRORS!", test_errors);
        end
        $display("==========================================================\n");

        $finish;
    end

endmodule
