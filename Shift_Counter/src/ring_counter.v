//ring counter

module ring_counter #(
    parameter N = 4
)(
    input wire clk,
    input wire rst,
    output reg [N-1:0] count
);

always @(posedge clk) begin
    if (rst) begin
        count <= {{(N-1){1'b0}},1'b1};
    end
    else begin
        count = {count[0], count[N-1:1]};
    end
end
endmodule