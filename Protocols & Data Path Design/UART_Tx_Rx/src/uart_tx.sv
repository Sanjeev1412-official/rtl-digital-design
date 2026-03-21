module uart_tx (
    input  logic clk,
    input  logic rst,
    input  logic baud_tick,
    input  logic start,
    input  logic [7:0] data_in,
    output logic tx,
    output logic busy
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [7:0] shift_reg;
    int bit_cnt;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx <= 1;
            busy <= 0;
            bit_cnt <= 0;
            shift_reg <= '0;
        end else begin
            // Latch a start request immediately (do not wait for baud_tick)
            if (state == IDLE) begin
                tx <= 1;
                busy <= 0;
                if (start) begin
                    shift_reg <= data_in;
                    state <= START;
                    busy <= 1;
                    bit_cnt <= 0;
                end
            end else if (baud_tick) begin
                // Bit timing and shifting happens on baud_tick
                case (state)
                    START: begin
                        tx <= 0;
                        state <= DATA;
                        bit_cnt <= 0;
                    end

                    DATA: begin
                        tx <= shift_reg[0];
                        shift_reg <= shift_reg >> 1;
                        if (bit_cnt == 7)
                            state <= STOP;
                        else
                            bit_cnt++;
                    end

                    STOP: begin
                        tx <= 1;
                        state <= IDLE;
                        busy <= 0;
                    end

                    default: begin
                        state <= IDLE;
                        tx <= 1;
                        busy <= 0;
                    end
                endcase
            end
        end
    end
endmodule