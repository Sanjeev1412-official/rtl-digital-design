// 2:1 mux using case statement
module mux_2to1_case (
    input wire a,
    input wire b,
    input wire selection,
    output reg y
);

    always @(*) begin
        case (selection)
            1'b0: y = a;
            1'b1: y = b;
            default: y = 1'b0;

        endcase
    end

endmodule