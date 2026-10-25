`timescale 1ns/1ps

module sync_fifo #(
    parameter int DATA_WIDTH          = 8,
    parameter int DEPTH               = 16,
    parameter int ALMOST_FULL_THRESH  = DEPTH - 2,
    parameter int ALMOST_EMPTY_THRESH = 2
)(
    input  logic                  clk,
    input  logic                  rst_n,

    // Write Interface
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  full,
    output logic                  almost_full,
    output logic                  overflow,

    // Read Interface
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  empty,
    output logic                  almost_empty,
    output logic                  underflow,

    // Status / Occupancy
    output logic [$clog2(DEPTH):0] data_cnt
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    // Internal Memory Array & Pointers
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH:0]   wr_ptr;
    logic [ADDR_WIDTH:0]   rd_ptr;

    // Internal Transfer Qualified Handshakes
    logic wr_valid;
    logic rd_valid;

    // Simultaneous Read & Write allowed when full (read frees up a slot)
    assign wr_valid = wr_en && (!full || rd_en);
    assign rd_valid = rd_en && !empty;

    // -------------------------------------------------------------
    // Status Flags Generation
    // -------------------------------------------------------------
    assign empty        = (data_cnt == 0);
    assign full         = (data_cnt == DEPTH);
    assign almost_empty = (data_cnt <= ALMOST_EMPTY_THRESH);
    assign almost_full  = (data_cnt >= ALMOST_FULL_THRESH);

    // -------------------------------------------------------------
    // Synchronous Memory Write
    // -------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (wr_valid) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end

    // -------------------------------------------------------------
    // Synchronous Memory Read (Registered Output)
    // -------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= '0;
        end else if (rd_valid) begin
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        end
    end

    // -------------------------------------------------------------
    // Pointer Management & Occupancy Counter
    // -------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= '0;
            rd_ptr    <= '0;
            data_cnt  <= '0;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else begin
            overflow  <= 1'b0;
            underflow <= 1'b0;

            // Write Pointer & Overflow Detection
            if (wr_valid) begin
                wr_ptr <= wr_ptr + 1'b1;
            end else if (wr_en && full && !rd_en) begin
                overflow <= 1'b1;
            end

            // Read Pointer & Underflow Detection
            if (rd_valid) begin
                rd_ptr <= rd_ptr + 1'b1;
            end else if (rd_en && empty) begin
                underflow <= 1'b1;
            end

            // Occupancy Counter Tracking
            case ({wr_valid, rd_valid})
                2'b10:   data_cnt <= data_cnt + 1'b1;
                2'b01:   data_cnt <= data_cnt - 1'b1;
                default: data_cnt <= data_cnt; // 2'b00 or 2'b11
            endcase
        end
    end

endmodule
