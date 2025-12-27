//siso shift register
module siso #(
    parameter N = 4
    )(
    input wire clk,
    input wire rst,
    input wire serial_in,
    output wire serial_out
    );

    reg [N-1:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= {N{1'b0}};
        end
        else begin
            shift_reg <= {serial_in, shift_reg[N-1:1]};
        end
    end

    assign serial_out = shift_reg[0];
endmodule


