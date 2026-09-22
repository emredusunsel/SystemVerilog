`timescale 1ps/1ps

module occ_tb;

    localparam DATA_WIDTH = 8;
    localparam POLYNOMIAL = 8'hA4;

    logic clk, rstn, start, finish;
    logic [DATA_WIDTH-1:0] data, data_out;

    occ # (
        .DATA_WIDTH(DATA_WIDTH),
        .POLYNOMIAL(POLYNOMIAL)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .start(start),
        .data(data),
        .data_out(data_out),
        .finish(finish)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        data = 8'h7B;

        #20;
        start = 1;
        rstn = 1;
        #10;
        start = 0;
        wait(finish);
        #20;
        start = 1;
        data = 8'h45;
        #10;
        start = 0;
        #100;
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, occ_tb);
    end

endmodule
