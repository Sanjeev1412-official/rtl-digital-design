module baud_gen #(
    parameter int CLK_FREQ = 50_000_000,
    parameter int BAUD_RATE = 9600,
    parameter int OVERSAMPLE = 16
)(
    input  logic clk,
    input  logic rst,
    output logic baud_tick,
    output logic sample_tick
);

    // sample_tick runs at BAUD_RATE * OVERSAMPLE
    localparam int SAMPLE_DIVISOR = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);

    int unsigned sample_counter;
    int unsigned os_counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sample_counter <= 0;
            os_counter <= 0;
            sample_tick <= 0;
            baud_tick <= 0;
        end else begin
            sample_tick <= 0;
            baud_tick <= 0;

            if (sample_counter == SAMPLE_DIVISOR-1) begin
                sample_counter <= 0;
                sample_tick <= 1;

                if (os_counter == OVERSAMPLE-1) begin
                    os_counter <= 0;
                    baud_tick <= 1;
                end else begin
                    os_counter <= os_counter + 1;
                end
            end else begin
                sample_counter <= sample_counter + 1;
            end
        end
    end

endmodule