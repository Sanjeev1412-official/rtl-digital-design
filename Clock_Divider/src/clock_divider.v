//clock divider

module clock_divider #(
    parameter N = 4
)(
    input wire clk_in,
    input wire rst,
    output reg clk_out

);

    integer count;
    
    always @(posedge clk_in) begin

        if (rst) begin
            count <= 0;
            clk_out <= 0;
        end
        else begin
            if (count == ((N/2)-1)) begin
                count <= 0;
                clk_out = ~clk_out;
            end
            else begin
                count <= count + 1;
            end
        end
    end
endmodule