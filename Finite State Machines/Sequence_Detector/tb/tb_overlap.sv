module tb_overlap;

    logic clk, rst, x, y;

    seq_overlap DUT (
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

    initial begin
        clk = 0;
        $dumpfile("Sequence_Detector/wave/tb_overlap.vcd");
        $dumpvars(0, tb_overlap);

        rst = 1;
        x = 0;
        @(negedge clk);
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

        #20
        @(negedge clk);
        $finish;
    end
endmodule