
module crc #(
    parameter int CRC_WIDTH  = 8,       // CRC register width
    parameter int DATA_WIDTH = 8,       // Input data width
    parameter int POLYNOMIAL = 8'b0000_1101,    // CRC polynomial
    parameter int INIT_VALUE = 0,       // Initial CRC value
    parameter int FINAL_XOR  = 0        // Value XORed with CRC at completion
) (
    input   logic                  clk,
    input   logic                  rstn,
    input   logic                  start,       //start a new CRC calculation
    input   logic                  data_valid,  //data is valid
    input   logic                  data_ready,  //CRC can accept data
    input   logic [DATA_WIDTH-1:0] data,        //input data word
    input   logic                  finish,      //mark the final data word
    output  logic                  crc_valid,   //final CRC is available
    output  logic [ CRC_WIDTH-1:0] crc,         //calculated CRC result
    output  logic                  busy         //CRC transaction is active
);

    logic [9:0] pol;
    assign pol = {1'b1, POLYNOMIAL};

    logic 

    logic [15:0] calc, pol_sh;

    always_ff @(posedge clk) begin : crc_block
        if (!rstn) begin
            calc <= {data, '0};
            pol_sh <= {pol, '0};
        end else begin
            if (calc[15-i])
                calc <= calc ^ {pol_sh};
            pol_sh <= pol_sh >> 1;
        end
    end

endmodule
