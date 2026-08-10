`timescale 1ps/1ps

module sync_ram_tb;

    localparam ADDR_WIDTH = 4;
    localparam DATA_WIDTH = 8;
    localparam DEPTH = 2**ADDR_WIDTH;

    logic clk, cs, we;
    logic [ADDR_WIDTH-1:0]  addr;
    logic [DATA_WIDTH-1:0]  data_i, data_o;

    sync_ram dut(
        .clk(clk),
        .addr(addr),
        .data_i(data_i),
        .cs(cs),
        .we(we),
        .data_o(data_o)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sync_ram_tb);

        $monitor("%t\t %b", $time, data_o);

        addr = '0;
        data_i = '0;
        cs = 1;
        we = 0;

        for (int i = 0; i < DEPTH; i ++) begin
            addr = addr + 1;
            data_i = data_i*0 + 2*i;
            we = 1; #10;
            we = 0; #10;
        end

        #20;
        $finish;
    end

endmodule
