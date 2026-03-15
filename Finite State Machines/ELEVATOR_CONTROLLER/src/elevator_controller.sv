module elevator_controller (
    input  logic       rst,
    input  logic       clk,
    input  logic       req0,
    input  logic       req1,
    input  logic       req2,
    output logic       motor_up,
    output logic       motor_down,
    output logic       door_open,
    output logic [1:0] current_floor
);

    typedef enum logic[1:0]{
        IDLE      = 2'd0,
        MOVE_UP   = 2'd1,
        MOVE_DOWN = 2'd2,
        DOOR_OPEN = 2'd3
    }state_t;

    state_t state, next_state;

    logic [1:0] target_floor;

    //---------------------------------------
    // FLOOR REGISTER
    //---------------------------------------

    always_ff @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            current_floor <= 2'd0;
        end
        else begin
            state <= next_state;

            if (state == MOVE_UP) begin
                if (current_floor < 2) current_floor <= current_floor + 2'd1;
            end
            else if (state == MOVE_DOWN) begin
                if (current_floor > 0) current_floor <= current_floor - 2'd1;
            end
        end
    end

     //---------------------------------------
    // TARGET FLOOR LOGIC
    //---------------------------------------

    always_comb begin
        target_floor = current_floor;

        if (req2) target_floor = 2;
        else if (req1) target_floor = 1;
        else if (req0) target_floor = 0;
    end

    //---------------------------------------
    // NEXT STATE LOGIC
    //---------------------------------------

    always_comb begin
        next_state = state;

        case(state)

            IDLE: begin
                if (target_floor > current_floor) next_state = MOVE_UP;
                else if (target_floor < current_floor) next_state = MOVE_DOWN;
                else if (req0 || req1 || req2) next_state = DOOR_OPEN;
            end
            MOVE_UP: begin
                if (current_floor == target_floor) next_state = DOOR_OPEN;
            end
            MOVE_DOWN: begin
                if (current_floor == target_floor) next_state = DOOR_OPEN;
            end
            DOOR_OPEN: begin
                next_state = IDLE;
            end
        endcase

    end

    //---------------------------------------
    // OUTPUT LOGIC
    //---------------------------------------

    always_comb begin
        motor_up = 0;
        motor_down = 0;
        door_open = 0;

        case (state)
            MOVE_UP: motor_up = 1;
            MOVE_DOWN: motor_down = 1;
            DOOR_OPEN: door_open = 1;
        endcase
    end

endmodule