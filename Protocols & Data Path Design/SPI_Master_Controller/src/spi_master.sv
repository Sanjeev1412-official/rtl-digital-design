`timescale 1ns/1ps

module spi_master #(
    parameter DATA_WIDTH = 8
)(
    input  logic                    clk,      // System clock
    input  logic                    rst_n,    // Active-low asynchronous reset
    input  logic                    start,    // Pulse to start transaction
    input  logic                    cpol,     // Clock Polarity (0: idle low, 1: idle high)
    input  logic                    cpha,     // Clock Phase (0: sample leading, 1: sample trailing)
    input  logic [7:0]              clk_div,  // Divider to generate SPI clock
    input  logic [DATA_WIDTH-1:0]   tx_data,  // Data to transmit
    
    output logic [DATA_WIDTH-1:0]   rx_data,  // Data received
    output logic                    busy,     // High while transaction is ongoing
    output logic                    done,     // 1-cycle pulse when complete
    
    // SPI Physical Interface
    output logic                    sclk,     // Serial clock
    output logic                    mosi,     // Master Out Slave In
    input  logic                    miso,     // Master In Slave Out
    output logic                    cs_n      // Chip Select (active low)
);

    // --- Internal Registers & States ---
    typedef enum logic [1:0] {IDLE, TRANSFER, DONE_ST} state_t;
    state_t state, next_state;

    logic [7:0]               baud_cnt;
    logic                     edge_pulse;      // Pulses at 2x the SPI baud rate
    logic [4:0]               edge_cnt;        // Counts up to DATA_WIDTH * 2 edges
    logic [DATA_WIDTH-1:0]    tx_shift_reg;
    logic [DATA_WIDTH-1:0]    rx_shift_reg;
    logic                     sclk_internal;   // Base SCLK before CPOL inversion

    // --- Baud Rate Generator (2x Oversampling) ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            baud_cnt   <= 8'd0;
            edge_pulse <= 1'b0;
        end else if (state == TRANSFER) begin
            if (baud_cnt == clk_div) begin
                baud_cnt   <= 8'd0;
                edge_pulse <= 1'b1;
            end else begin
                baud_cnt   <= baud_cnt + 1'b1;
                edge_pulse <= 1'b0;
            end
        end else begin
            baud_cnt   <= 8'd0;
            edge_pulse <= 1'b0;
        end
    end

    // --- FSM Next State Logic ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:     if (start) next_state = TRANSFER;
            TRANSFER: if (edge_cnt == (DATA_WIDTH * 2)) next_state = DONE_ST;
            DONE_ST:  next_state = IDLE;
            default:  next_state = IDLE;
        endcase
    end

    // --- Edge Counter & Clock Toggle ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_cnt      <= 5'd0;
            sclk_internal <= 1'b0;
        end else if (state == IDLE) begin
            edge_cnt      <= 5'd0;
            sclk_internal <= cpha; // Pre-load SCLK based on phase mode
        end else if (state == TRANSFER && edge_pulse) begin
            edge_cnt      <= edge_cnt + 1'b1;
            sclk_internal <= ~sclk_internal; // Toggle SCLK at every edge pulse
        end
    end

    // --- Datapath: TX and RX Shift Registers ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_shift_reg <= '0;
            rx_shift_reg <= '0;
        end else if (state == IDLE && start) begin
            tx_shift_reg <= tx_data;
        end else if (state == TRANSFER && edge_pulse) begin
            // Shift Data Logic (Depends on CPHA)
            if ((!cpha && !sclk_internal) || (cpha && sclk_internal)) begin
                tx_shift_reg <= {tx_shift_reg[DATA_WIDTH-2:0], 1'b0}; // Shift left
            end
            // Sample Data Logic (Depends on CPHA)
            if ((!cpha && sclk_internal) || (cpha && !sclk_internal)) begin
                rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], miso}; // Capture MISO
            end
        end
    end

    // --- Output Assignments ---
    assign sclk    = (state == TRANSFER) ? (sclk_internal ^ cpol) : cpol;
    assign mosi    = tx_shift_reg[DATA_WIDTH-1]; // MSB first
    assign cs_n    = ~(state == TRANSFER);
    assign busy    = (state != IDLE);
    assign done    = (state == DONE_ST);
    assign rx_data = rx_shift_reg;

    // --- SystemVerilog Assertions (SVA) ---
`ifndef __ICARUS__
    // Full SVA for commercial formal and simulation tools (VCS / Questa / JasperGold)
    property p_mutex_flags;
        @(posedge clk) disable iff (!rst_n)
        not (busy && done);
    endproperty
    assert property (p_mutex_flags) else $error("SVA Failure: busy and done asserted simultaneously.");

    property p_cs_n_active;
        @(posedge clk) disable iff (!rst_n)
        $changed(sclk) |-> (cs_n == 1'b0);
    endproperty
    assert property (p_cs_n_active) else $error("SVA Failure: SCLK toggled while CS_N was high.");
`endif

endmodule