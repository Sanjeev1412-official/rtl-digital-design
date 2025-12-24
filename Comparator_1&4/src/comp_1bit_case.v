//1-bit comparator
module comp_1bit_case(
    input wire a,
    input wire b,
    output reg gt,
    output reg lt,
    output reg eq
);

    always @(*) begin
        case ({a,b})
            2'b00: begin gt = 0; lt = 0; eq = 1; end
            2'b01: begin gt = 0; lt = 1; eq = 0; end
            2'b10: begin gt = 1; lt = 0; eq = 0; end
            2'b11: begin gt = 0; lt = 0; eq = 1; end
            default: begin gt = 0; lt = 0; eq = 0; end
        endcase
    end
endmodule