`timescale 1ns/1ps

module n_bit_adder_tb();
    parameter N = 8;
    reg [N-1:0] a;
    reg [N-1:0] b;
    reg cin;
    wire [N-1:0] sum;
    wire cout;

    n_bit_adder #(.N(N)) uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        //dumpfile
        $dumpfile("wave/n_bit_adder.vcd");
        $dumpvars(0, n_bit_adder_tb);

        //testcases with display
        $monitor("Time=%0t : a=%d, b=%d, cin=%b => sum=%d, cout=%b", $time, a, b, cin, sum, cout);
        a = 0; b = 0; cin = 0; #10;
        a = 5; b = 10; cin = 0; #10;
        a = 15; b = 20; cin = 1; #10;
        a = 255; b = 1; cin = 0; #10;
        a = 128; b = 128; cin = 1; #10;

        //random testcases
        repeat (10) begin
            a = $random % (1 << N);
            b = $random % (1 << N);
            cin = $random % 2;
            #10;
        end
        $finish;


    end
endmodule