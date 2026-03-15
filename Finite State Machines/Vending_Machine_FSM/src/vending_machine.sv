module vending_machine (
    input  logic clk,
    input  logic rst,

    input  logic coin_5,
    input  logic coin_10,

    output logic dispense,
    output logic change_5
);


    // FSM state definition

    typedef enum logic [2:0] {
        S0_IDLE   = 3'd0,  // ₹0
        S1_5      = 3'd1,  // ₹5
        S2_10     = 3'd2,  // ₹10
        S3_15     = 3'd3,  // ₹15  dispense
        S4_20     = 3'd4   // ₹20  dispense + change
    } state_t;

    state_t state, next_state;

    // STATE REGISTER

    always_ff @(posedge clk) begin
        if (rst)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // NEXT-STATE LOGIC
    always_comb begin
        next_state = state;

        case (state)
            S0_IDLE: begin
                if (coin_5) begin
                    next_state = S1_5;
                end
                else if (coin_10) begin
                    next_state = S2_10;
                end
                else begin
                    next_state = S0_IDLE;
                end
            end
            S1_5: begin
                if (coin_5) begin
                    next_state = S2_10;
                end
                else if (coin_10) begin
                    next_state = S3_15;
                end
                else begin
                    next_state = S1_5;
                end
            end
            S2_10: begin
                if (coin_5) begin
                    next_state = S3_15;
                end
                else if (coin_10) begin
                    next_state = S4_20;
                end
                else begin
                    next_state = S2_10;
                end
            end
            S3_15: begin
                next_state = S0_IDLE;
            end
            S4_20: begin
                next_state = S0_IDLE;
            end
            default: begin
                next_state = S0_IDLE;
            end
        endcase
    end

    // OUTPUT LOGIC
    always_comb begin
        dispense = 0;
        change_5 = 0;

        case (state)
            S3_15: begin
                dispense = 1;
            end
            S4_20: begin
                dispense = 1;
                change_5 = 1;
            end
            default: begin
                dispense = 0;
                change_5 = 0;
            end
        endcase
    end

endmodule
