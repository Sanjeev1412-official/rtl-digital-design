module seq_overlap (
    input  logic clk,
    input  logic rst,
    input  logic x,
    output logic y
);

    typedef enum logic [1:0]{ 
        S0 = 2'd0, 
        S1 = 2'd1, 
        S2 = 2'd2,
        S3 = 2'd3
     } state_t;

    state_t state, next_state;

    always_ff @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        y = 0;

        case(state)
            S0: begin
                if (x) next_state = S1;
            end
            S1: begin
                if (!x) next_state = S2;
                else    next_state = S1;
            end
            S2: begin
                if (x)
                    next_state = S3;
                else    next_state = S0;
            end
            S3: begin
                if (x) begin
                    next_state = S1;
                    y = 1;
                end else begin
                    next_state = S2;
                end
            end


        endcase
    end

endmodule