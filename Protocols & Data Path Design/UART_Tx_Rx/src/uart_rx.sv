module uart_rx #(
    parameter int OVERSAMPLE = 16
)(
    input  logic clk,
    input  logic rst,
    input  logic sample_tick,
    input  logic rx,
    output logic [7:0] data_out,
    output logic valid
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    int unsigned sample_cnt;
    int unsigned bit_cnt;
    logic [7:0] shift_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sample_cnt <= 0;
            bit_cnt <= 0;
            valid <= 0;
            shift_reg <= '0;
            data_out <= '0;
        end else if (sample_tick) begin
            case (state)

                IDLE: begin
                    valid <= 0;
                    if (rx == 0) begin
                        state <= START;
                        sample_cnt <= 0;
                    end
                end

                START: begin
                    if (sample_cnt == OVERSAMPLE/2) begin
                        if (rx == 0) begin
                            state <= DATA;
                            sample_cnt <= 0;
                            bit_cnt <= 0;
                        end else begin
                            state <= IDLE;
                            sample_cnt <= 0;
                        end
                    end else sample_cnt++;
                end

                DATA: begin
                    // Sample in the middle of each bit period
                    if (sample_cnt == (OVERSAMPLE/2)) begin
                        shift_reg[bit_cnt] <= rx;
                    end

                    // Advance to next bit after a full bit period
                    if (sample_cnt == OVERSAMPLE-1) begin
                        sample_cnt <= 0;
                        if (bit_cnt == 7)
                            state <= STOP;
                        else
                            bit_cnt++;
                    end else begin
                        sample_cnt++;
                    end
                end

                STOP: begin
                    if (sample_cnt == OVERSAMPLE-1) begin
                        data_out <= shift_reg;
                        valid <= 1;
                        state <= IDLE;
                        sample_cnt <= 0;
                    end else sample_cnt++;
                end
            endcase
        end
    end
endmodule