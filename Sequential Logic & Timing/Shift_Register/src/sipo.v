//sipo shift register
module sipo #(
    parameter N = 4
    )(
    input wire clk,
    input wire rst,
    input wire serial_in,
    output reg [N-1:0] parallel_out
    );

    always @(posedge clk) begin
        if (rst) begin
            parallel_out <= {N{1'b0}};
        end
        else begin
            parallel_out <= {parallel_out[N-2:0], serial_in};
        end
    end

endmodule


