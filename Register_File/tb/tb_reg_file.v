`timescale 1ns/1ps

module tb_reg_file;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3;
    parameter DEPTH = 1 << ADDR_WIDTH;


    reg clk;
    reg rst;
    reg we;
    reg [ADDR_WIDTH-1:0] read_addr1;
    reg [ADDR_WIDTH-1:0] read_addr2;
    reg [ADDR_WIDTH-1:0] write_addr;
    reg [DATA_WIDTH-1:0] write_data;
    wire [DATA_WIDTH-1:0] read_data1;
    wire [DATA_WIDTH-1:0] read_data2;
    
    reg_file #(
        .DATA_WIDTH 	(DATA_WIDTH          ),
        .ADDR_WIDTH 	(ADDR_WIDTH           ),
        .DEPTH      	(DEPTH   ))
    dut(
        .clk        	(clk         ),
        .rst        	(rst         ),
        .we         	(we          ),
        .read_addr1 	(read_addr1  ),
        .read_addr2 	(read_addr2  ),
        .write_addr 	(write_addr  ),
        .write_data 	(write_data  ),
        .read_data1 	(read_data1  ),
        .read_data2 	(read_data2  )
    );
    

    initial clk = 0;
    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display("Time: %0t | rst: %b | we: %b | waddr: %h | wdata: %h | raddr1: %h | rdata1: %h | raddr2: %h | rdata2: %h",
                 $time, rst, we, write_addr, write_data, read_addr1, read_data1, read_addr2, read_data2);
    end

    initial begin
        $dumpfile("Register_File/wave/reg_file.vcd");
        $dumpvars(0, tb_reg_file);

        // Initialize
        rst = 1; we = 0; write_addr = 0; write_data = 0; read_addr1 = 0; read_addr2 = 0;

        // Release reset
        @(negedge clk);
        rst = 0;

        // Write data to register 3
        @(negedge clk);
        we = 1; write_addr = 3; write_data = 8'hAA;

        // Write data to register 5
        @(negedge clk);
        we = 1; write_addr = 5; write_data = 8'h55;
        // Disable write
        @(negedge clk);
        we = 0;

        // Read from register 3 and 5
        @(negedge clk);
        read_addr1 = 3; read_addr2 = 5;

        // Read from register 0 and 1
        @(negedge clk);
        read_addr1 = 0; read_addr2 = 1;
        // Finish simulation
        @(negedge clk);
        $finish;
    end

endmodule