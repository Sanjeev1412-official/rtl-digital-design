module tb_nonoverlap;

    logic clk, rst, x, y;

    seq_nonoverlap DUT (
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        #1;
        $display(
            "Time=%0t | rst=%b | x=%b | y=%b", 
            $time, rst, x, y
        );
    end
    initial clk = 0;
    initial begin
        $dumpfile("Sequence_Detector/wave/tb_nonoverlap.vcd");
        $dumpvars(0, tb_nonoverlap);

        rst = 1;
        x = 0;
        #10;
        rst = 0;

        // apply bits: 1011011

        x=1; #10;
        x=0; #10;
        x=1; #10;
        x=1; #10;
        x=0; #10;
        x=1; #10;
        x=1; #10;

        #20 $finish;
    end
endmodule