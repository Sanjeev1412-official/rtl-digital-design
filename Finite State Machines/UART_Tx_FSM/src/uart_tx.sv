module uart_tx (

    input  logic clk,
    input  logic rst,

    input  logic tx_start,
    input  logic [7:0] data_in,

    output logic tx,
    output logic tx_done
);

    typedef enum logic[1:0]{
        IDLE  = 2'd0,
        START = 2'd1,
        DATA  = 2'd2,
        STOP  = 2'd3
    } state_t;

    state_t state, next_state;

    logic [7:0] shift_reg;
    logic [3:0] bit_count;

    // Icarus workaround: avoid constant bit-select directly inside always_comb.
    logic shift_reg_lsb;
    assign shift_reg_lsb = shift_reg[0];

    //---------------------------------------
    // STATE REGISTER
    //---------------------------------------

    always_ff @(posedge clk) begin

        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    //---------------------------------------
    // DATA REGISTER
    //---------------------------------------

    always_ff @(posedge clk) begin
        if(tx_start)
            shift_reg <= data_in;
        else if (state == DATA)
            shift_reg <= shift_reg >> 1;
    end

    //---------------------------------------
    // BIT COUNTER
    //---------------------------------------

    always_ff @(posedge clk) begin
        if (rst)
            bit_count <= 0;
        else if (state == DATA)
            bit_count <= bit_count + 1;
        else
            bit_count <= 0;
    end

    //---------------------------------------
    // NEXT STATE LOGIC
    //---------------------------------------

    always_comb begin
        next_state = state;

        case(state)
            IDLE: begin
                if(tx_start)
                    next_state = START;
            end
            START: begin
                next_state = DATA;
            end
            DATA: begin
                if(bit_count == 7)
                    next_state = STOP;
            end
            STOP: begin
                next_state = IDLE;
            end
        endcase
    end

    //---------------------------------------
    // OUTPUT LOGIC
    //---------------------------------------

    always_comb begin
        tx = 1;
        tx_done = 0;

        case(state)

            IDLE:
                tx = 1;

            START:
                tx = 0;

            DATA:
                tx = shift_reg_lsb;

            STOP: begin
                tx = 1;
                tx_done = 1;
            end

        endcase
    end

endmodule