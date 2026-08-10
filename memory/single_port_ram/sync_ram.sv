
module sync_ram #(
    parameter int ADDR_WIDTH = 4,
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 2**ADDR_WIDTH
) (
    input   logic                       clk,
    input   logic   [ADDR_WIDTH-1:0]    addr,
    input   logic   [DATA_WIDTH-1:0]    data_i,
    input   logic                       cs,
    input   logic                       we,
    output  logic   [DATA_WIDTH-1:0]    data_o
);
    
    logic [DATA_WIDTH-1:0] mem [DEPTH];

    always_ff @(posedge clk) begin : write
        if (cs & we)
            mem[addr] <= data_i;
    end

    assign data_o = (cs & !we) ? mem[addr] : '0;

endmodule
