`timescale 1ps/1ps

module shift_register_tb;

    localparam int WIDTH = 8;

    logic               clk, rstn, en, serial_in, dir;
    logic   [WIDTH-1:0] q;

    shift_register #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .serial_in(serial_in),
        .dir(dir),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Time\t rstn en dir serial_in q");
        $monitor("%0t\t %b    %b  %b   %b         %b",
                 $time, rstn, en, dir, serial_in, q);

        rstn = 0;
        en = 0;
        serial_in = 1;
        dir = 0;
        #15;

        rstn = 1;
        en = 1;
        #40;

        dir = 1;
        #40;

        dir = 0;
        #80;
        serial_in = 0;
        dir = 1;
        #80;

        $finish;
    end

endmodule
