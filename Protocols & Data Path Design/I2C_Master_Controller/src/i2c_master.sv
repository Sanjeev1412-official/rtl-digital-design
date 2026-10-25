`timescale 1ns/1ps
module i2c_master #(
    parameter int CLK_FREQ = 50_000_000, // System clock frequency in Hz (e.g. 50 MHz)
    parameter int I2C_FREQ = 100_000     // I2C SCL frequency in Hz (Standard Mode = 100 kHz)
)(
    // System Clock and Reset
    input  logic        clk,
    input  logic        rst_n,

    // Host Control Interface
    input  logic        start,       // Pulse high for 1 cycle to launch transaction
    input  logic        rw,          // 0 = Write to Slave, 1 = Read from Slave
    input  logic [6:0]  addr,        // 7-bit Slave Address
    input  logic [7:0]  tx_data,     // Data byte to write

    // Host Status Interface
    output logic [7:0]  rx_data,     // Data byte read from slave
    output logic        busy,        // High while transaction is in progress
    output logic        done,        // 1-cycle pulse upon transaction completion
    output logic        ack_error,   // High if slave did not acknowledge address or data

    // Physical I2C Bus (Connect to bidirectional FPGA pads with external pull-ups)
    inout  wire         scl,
    inout  wire         sda
);


    // Each SCL cycle is divided into 4 equal quarters
    localparam int QUARTER_DIV = CLK_FREQ / (I2C_FREQ * 4);
    localparam int DIV_WIDTH   = $clog2(QUARTER_DIV);

    logic [DIV_WIDTH-1:0] clk_cnt;
    logic [1:0]           phase;       // 0: Setup, 1: SCL Rise, 2: Sample/Action, 3: SCL Fall
    logic                 phase_tick;  // Pulses at every quarter-SCL boundary


    typedef enum logic [3:0] {
        IDLE        = 4'd0,
        START_ST    = 4'd1,
        ADDR_ST     = 4'd2,
        ACK_ADDR_ST = 4'd3,
        WRITE_ST    = 4'd4,
        ACK_DATA_ST = 4'd5,
        READ_ST     = 4'd6,
        MASTER_ACK  = 4'd7,
        STOP_ST     = 4'd8,
        DONE_ST     = 4'd9
    } state_t;

    state_t state, next_state;


    logic [2:0] bit_cnt;         // Counts 8 bits (7 down to 0)
    logic [7:0] tx_shift;       // Latched {addr, rw} or tx_data
    logic [7:0] rx_shift;       // Shift register for incoming data
    logic       saved_rw;       // Latched transfer direction
    logic       scl_oen;        // 1: Pull SCL Low, 0: Release SCL to High-Z
    logic       sda_oen;        // 1: Pull SDA Low, 0: Release SDA to High-Z
    logic       scl_in;         // Sampled SCL line
    logic       sda_in;         // Sampled SDA line

   
    assign scl    = (scl_oen) ? 1'b0 : 1'bz;
    assign sda    = (sda_oen) ? 1'b0 : 1'bz;
    assign scl_in = scl;
    assign sda_in = sda;

    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_cnt    <= '0;
            phase      <= 2'd0;
            phase_tick <= 1'b0;
        end else if (state != IDLE && state != DONE_ST) begin
            if (clk_cnt == QUARTER_DIV - 1) begin
                clk_cnt    <= '0;
                phase      <= phase + 1'b1;
                phase_tick <= 1'b1;
            end else begin
                clk_cnt    <= clk_cnt + 1'b1;
                phase_tick <= 1'b0;
            end
        end else begin
            clk_cnt    <= '0;
            phase      <= 2'd0;
            phase_tick <= 1'b0;
        end
    end

   
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            bit_cnt    <= 3'd7;
            tx_shift   <= 8'h00;
            rx_shift   <= 8'h00;
            rx_data    <= 8'h00;
            saved_rw   <= 1'b0;
            ack_error  <= 1'b0;
            done       <= 1'b0;
        end else begin
            done <= 1'b0; // Default pulse behavior

            case (state)
        
                IDLE: begin
                    if (start) begin
                        ack_error <= 1'b0;
                        saved_rw  <= rw;
                        tx_shift  <= {addr, rw}; 
                        state     <= START_ST;
                    end
                end

        
                START_ST: begin
                    if (phase_tick && (phase == 2'd3)) begin
                        bit_cnt <= 3'd7;
                        state   <= ADDR_ST;
                    end
                end

            
                ADDR_ST: begin
                    if (phase_tick && (phase == 2'd3)) begin
                        if (bit_cnt == 3'd0) begin
                            state <= ACK_ADDR_ST;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end
                end

               
                ACK_ADDR_ST: begin
                    if (phase_tick && (phase == 2'd2)) begin
                        if (sda_in == 1'b1) begin
                            ack_error <= 1'b1;
                        end
                    end

                    if (phase_tick && (phase == 2'd3)) begin
                        if (ack_error) begin
                            state <= STOP_ST; 
                        end else begin
                            bit_cnt <= 3'd7;
                            if (saved_rw == 1'b0) begin
                                tx_shift <= tx_data; 
                                state    <= WRITE_ST;
                            end else begin
                                state    <= READ_ST;
                            end
                        end
                    end
                end

              
                WRITE_ST: begin
                    if (phase_tick && (phase == 2'd3)) begin
                        if (bit_cnt == 3'd0) begin
                            state <= ACK_DATA_ST;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end
                end

               
                ACK_DATA_ST: begin
                    if (phase_tick && (phase == 2'd2)) begin
                        if (sda_in == 1'b1) begin
                            ack_error <= 1'b1;
                        end
                    end

                    if (phase_tick && (phase == 2'd3)) begin
                        state <= STOP_ST;
                    end
                end

               
                READ_ST: begin
                    if (phase_tick && (phase == 2'd2)) begin
                        rx_shift[bit_cnt] <= sda_in; 
                    end

                    if (phase_tick && (phase == 2'd3)) begin
                        if (bit_cnt == 3'd0) begin
                            state <= MASTER_ACK;
                        end else begin
                            bit_cnt <= bit_cnt - 1'b1;
                        end
                    end
                end

               
                MASTER_ACK: begin
                    if (phase_tick && (phase == 2'd3)) begin
                        rx_data <= rx_shift;
                        state   <= STOP_ST;
                    end
                end

               
                STOP_ST: begin
                    if (phase_tick && (phase == 2'd3)) begin
                        state <= DONE_ST;
                    end
                end

               
                DONE_ST: begin
                    done  <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

   
    always_comb begin
        
        scl_oen = 1'b0;
        sda_oen = 1'b0;
        busy    = (state != IDLE);

        case (state)
            IDLE: begin
                scl_oen = 1'b0; // SCL released HIGH
                sda_oen = 1'b0; // SDA released HIGH
            end

            START_ST: begin
                
                case (phase)
                    2'd0: begin scl_oen = 1'b0; sda_oen = 1'b0; end
                    2'd1: begin scl_oen = 1'b0; sda_oen = 1'b0; end
                    2'd2: begin scl_oen = 1'b0; sda_oen = 1'b1; end 
                    2'd3: begin scl_oen = 1'b1; sda_oen = 1'b1; end
                endcase
            end

            ADDR_ST: begin
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = ~tx_shift[bit_cnt]; 
            end

            ACK_ADDR_ST: begin
                // Master releases SDA so Slave can pull it LOW for ACK
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = 1'b0; // Release SDA to Slave
            end

            WRITE_ST: begin
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = ~tx_shift[bit_cnt];
            end

            ACK_DATA_ST: begin
                // Master releases SDA so Slave can pull it LOW for ACK
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = 1'b0; // Release SDA to Slave
            end

            READ_ST: begin
                // Master reads data driven by Slave
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = 1'b0; // Release SDA to Slave
            end

            MASTER_ACK: begin
               
                scl_oen = (phase == 2'd0 || phase == 2'd3);
                sda_oen = 1'b0; // Drive NACK (release SDA)
            end

            STOP_ST: begin

                case (phase)
                    2'd0: begin scl_oen = 1'b1; sda_oen = 1'b1; end
                    2'd1: begin scl_oen = 1'b0; sda_oen = 1'b1; end
                    2'd2: begin scl_oen = 1'b0; sda_oen = 1'b0; end // STOP edge
                    2'd3: begin scl_oen = 1'b0; sda_oen = 1'b0; end
                endcase
            end

            DONE_ST: begin
                scl_oen = 1'b0;
                sda_oen = 1'b0;
            end

            default: begin
                scl_oen = 1'b0;
                sda_oen = 1'b0;
            end
        endcase
    end

endmodule
