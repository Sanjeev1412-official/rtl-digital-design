//up_down_counter

module up_down_counter #(
    parameter N = 4
    )(
        input wire clk,
        input wire rst,
        input wire en,
        input wire up_down,
        output reg [N-1:0] count
    );

    always @(posedge clk) begin
        if (rst) begin
            count = {N{1'b0}};
        end
        else if (en) begin
            if (up_down) begin
                count <= count + 1'b1;
            end
            else begin
                count <= count - 1'b1;
            end
        end
        else begin
            count <= count;
        end
    end
endmodule