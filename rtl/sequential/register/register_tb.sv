`timescale 1ps/1ps

module register_tb;

    localparam WIDTH = 8;
    localparam logic [WIDTH-1:0] RESET_VALUE = '0;

    logic clk, rstn, en;
    logic [WIDTH-1:0] in, out;

    register #(
        .WIDTH(WIDTH), .RESET_VALUE(RESET_VALUE)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .en     (en),
        .in     (in),
        .out    (out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic reg_write(logic [WIDTH-1:0] data);
        @(negedge clk);
        in = data;
        en = 1;

        @(negedge clk);
        en = 0;
    endtask

    task automatic check(logic [WIDTH-1:0] expected);
        if (out == expected)
            $display("PASS: out = %b", out);
        else
            $display("FAIL: expected = %b, got = %b", expected, out);
    endtask

    initial begin
        rstn = 0;
        en = 0;
        #10;
        rstn = 1;

        reg_write(8'haa);
        check(8'haa);
        reg_write(8'hbb);
        check(8'hbb);
        reg_write(8'hcc);
        check(8'hcc);
        reg_write(8'hdd);
        check(8'hdd);

        en = 0;
        in = 8'hee;
        check(8'hdd);

        $finish;
    end

endmodule
