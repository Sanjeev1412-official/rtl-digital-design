module uart_top (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic [7:0] tx_data,
    output logic tx,
    output logic busy,
    input  logic rx,
    output logic [7:0] rx_data,
    output logic valid
);

    logic baud_tick;
    logic sample_tick;

    baud_gen bg(
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .sample_tick(sample_tick)
    );

    uart_tx tx_inst(
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .start(start),
        .data_in(tx_data),
        .tx(tx),
        .busy(busy)
    );

    uart_rx rx_inst(
        .clk(clk),
        .rst(rst),
        .sample_tick(sample_tick),
        .rx(rx),
        .data_out(rx_data),
        .valid(valid)
    );
endmodule