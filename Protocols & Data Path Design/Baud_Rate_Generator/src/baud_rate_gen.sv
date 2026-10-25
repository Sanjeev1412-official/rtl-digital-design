`timescale 1ns/1ps

module baud_rate_gen #(
    parameter int CLK_FREQ   = 50_000_000,
    parameter int OVERSAMPLE = 16
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        enable,
    input  logic [2:0]  baud_sel,
    input  logic [15:0] custom_div,
    input  logic        custom_en,
    output logic        sample_tick,
    output logic        baud_tick
);

    // Precomputed rounded integer divisors for standard baud rates
    localparam int DIV_9600   = (CLK_FREQ + (9600   * OVERSAMPLE)/2) / (9600   * OVERSAMPLE);
    localparam int DIV_19200  = (CLK_FREQ + (19200  * OVERSAMPLE)/2) / (19200  * OVERSAMPLE);
    localparam int DIV_38400  = (CLK_FREQ + (38400  * OVERSAMPLE)/2) / (38400  * OVERSAMPLE);
    localparam int DIV_57600  = (CLK_FREQ + (57600  * OVERSAMPLE)/2) / (57600  * OVERSAMPLE);
    localparam int DIV_115200 = (CLK_FREQ + (115200 * OVERSAMPLE)/2) / (115200 * OVERSAMPLE);
    localparam int DIV_230400 = (CLK_FREQ + (230400 * OVERSAMPLE)/2) / (230400 * OVERSAMPLE);
    localparam int DIV_460800 = (CLK_FREQ + (460800 * OVERSAMPLE)/2) / (460800 * OVERSAMPLE);
    localparam int DIV_921600 = (CLK_FREQ + (921600 * OVERSAMPLE)/2) / (921600 * OVERSAMPLE);

    logic [15:0] target_div;
    logic [15:0] sample_cnt;
    logic [3:0]  os_cnt;

    // Divisor Selection Mux
    always_comb begin
        if (custom_en) begin
            target_div = (custom_div > 16'd1) ? custom_div : 16'd2;
        end else begin
            case (baud_sel)
                3'b000: target_div = 16'(DIV_9600);
                3'b001: target_div = 16'(DIV_19200);
                3'b010: target_div = 16'(DIV_38400);
                3'b011: target_div = 16'(DIV_57600);
                3'b100: target_div = 16'(DIV_115200);
                3'b101: target_div = 16'(DIV_230400);
                3'b110: target_div = 16'(DIV_460800);
                3'b111: target_div = 16'(DIV_921600);
                default: target_div = 16'(DIV_9600);
            endcase
        end
    end

    // Tick Generator Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt  <= '0;
            os_cnt      <= '0;
            sample_tick <= 1'b0;
            baud_tick   <= 1'b0;
        end else if (enable) begin
            sample_tick <= 1'b0;
            baud_tick   <= 1'b0;

            if (sample_cnt >= target_div - 1) begin
                sample_cnt  <= '0;
                sample_tick <= 1'b1;

                if (os_cnt >= OVERSAMPLE - 1) begin
                    os_cnt    <= '0;
                    baud_tick <= 1'b1;
                end else begin
                    os_cnt <= os_cnt + 1'b1;
                end
            end else begin
                sample_cnt <= sample_cnt + 1'b1;
            end
        end else begin
            sample_cnt  <= '0;
            os_cnt      <= '0;
            sample_tick <= 1'b0;
            baud_tick   <= 1'b0;
        end
    end

endmodule
