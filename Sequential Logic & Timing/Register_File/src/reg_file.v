//register file

module reg_file #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH = 1 << ADDR_WIDTH
)(
    input wire clk,
    input wire rst,
    input wire we,
    input wire [ADDR_WIDTH-1:0] read_addr1,
    input wire [ADDR_WIDTH-1:0] read_addr2,
    input wire [ADDR_WIDTH-1:0] write_addr,
    input wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH-1:0] read_data1,
    output wire [DATA_WIDTH-1:0] read_data2
);

    // Register array
    reg [DATA_WIDTH-1:0] reg_array [0:DEPTH-1];
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1)
                reg_array[i] <= {DATA_WIDTH{1'b0}};
        end
        else if (we) begin
            reg_array[write_addr] <= write_data;
        end
    end

    assign read_data1 = reg_array[read_addr1];
    assign read_data2 = reg_array[read_addr2];
    
endmodule