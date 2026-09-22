module crc8_msb_parallel #(
    parameter logic [7:0] POLY = 8'h07,
    parameter logic [7:0] SEED = 8'h00
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       clear,
    input  logic [7:0] data_in,   // 8-bit byte input
    input  logic       enable,    // High when data_in byte is valid
    output logic [7:0] crc_out
);

    logic [7:0] crc_reg;
    logic [7:0] next_crc;

    // Combinational function calculating 8 bits of MSB-first shift logic
    function automatic logic [7:0] calc_next_crc(logic [7:0] current_crc, logic [7:0] data);
        logic [7:0] temp_crc;
        temp_crc = current_crc ^ data;
        
        for (int i = 0; i < 8; i++) begin
            if (temp_crc[7]) begin
                temp_crc = (temp_crc << 1) ^ POLY;
            end else begin
                temp_crc = (temp_crc << 1);
            end
        end
        return temp_crc;
    endfunction

    assign next_crc = calc_next_crc(crc_reg, data_in);
    assign crc_out  = crc_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            crc_reg <= SEED;
        end else if (clear) begin
            crc_reg <= SEED;
        end else if (enable) begin
            crc_reg <= next_crc;
        end
    end

endmodule