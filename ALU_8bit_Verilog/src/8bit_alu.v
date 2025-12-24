// 8-bit alu: add, sub, and, or
module alu_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input  [1:0] opcode,
    output reg [7:0] y,
    output reg carryout,
    output reg zero
);

always @(*) begin
    carryout = 0;

    case (opcode)
        2'b00: {carryout, y} = a + b; // addition
        2'b01: {carryout, y} = a - b; // subtraction
        2'b10: y = a & b;             // and
        2'b11: y = a | b;             // or
        default: y = 8'b0;
    endcase

    zero = (y == 8'b0);
end

endmodule
