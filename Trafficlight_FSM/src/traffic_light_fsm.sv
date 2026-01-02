// traffic light controller using SystemVerilog FSM
module traffic_light_fsm #(
    parameter int GREEN_TIME  = 5,
    parameter int YELLOW_TIME = 2
)(
    input  logic clk,
    input  logic rst,

    // north-south lights
    output logic ns_red,
    output logic ns_yellow,
    output logic ns_green,

    // east-west lights
    output logic ew_red,
    output logic ew_yellow,
    output logic ew_green
);


    // state encoding (SystemVerilog enum)

    typedef enum logic [1:0] {
        S0_NS_GREEN  = 2'b00,
        S1_NS_YELLOW = 2'b01,
        S2_EW_GREEN  = 2'b10,
        S3_EW_YELLOW = 2'b11
    } state_t;

    state_t state, next_state;

    int timer;


    // state register + timer (sequential)

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S0_NS_GREEN;
            timer <= 0;
        end
        else begin
            state <= next_state;

            if (state != next_state)
                timer <= 0;
            else
                timer <= timer + 1;
        end
    end


    // next-state logic (combinational)

    always_comb begin
        next_state = state;  // DEFAULT (prevents latches)

        case (state)
            S0_NS_GREEN: begin
                if (timer == GREEN_TIME - 1)
                    next_state = S1_NS_YELLOW;
            end

            S1_NS_YELLOW: begin
                if (timer == YELLOW_TIME - 1)
                    next_state = S2_EW_GREEN;
            end

            S2_EW_GREEN: begin
                if (timer == GREEN_TIME - 1)
                    next_state = S3_EW_YELLOW;
            end

            S3_EW_YELLOW: begin
                if (timer == YELLOW_TIME - 1)
                    next_state = S0_NS_GREEN;
            end

            default: begin
                next_state = S0_NS_GREEN;
            end
        endcase
    end

    // output logic (Moore FSM)

    always_comb begin
        // default: all red
        ns_red    = 1;
        ns_yellow = 0;
        ns_green  = 0;

        ew_red    = 1;
        ew_yellow = 0;
        ew_green  = 0;

        if (!rst) begin
            unique case (state)
                S0_NS_GREEN: begin
                    ns_red   = 0;
                    ns_green = 1;
                end

                S1_NS_YELLOW: begin
                    ns_red    = 0;
                    ns_yellow = 1;
                end

                S2_EW_GREEN: begin
                    ew_red   = 0;
                    ew_green = 1;
                end

                S3_EW_YELLOW: begin
                    ew_red    = 0;
                    ew_yellow = 1;
                end

                default: begin
                    // keep defaults (all red)
                end
            endcase
        end
    end

endmodule
