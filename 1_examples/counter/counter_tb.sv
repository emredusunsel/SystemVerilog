`timescale 1ps/1ps

module counter_tb;

    localparam int WIDTH = 4;

    logic clk, rstn, en, dir;
    logic [WIDTH-1:0] q;

    counter #(
        .WIDTH(WIDTH)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .en     (en),
        .dir    (dir),
        .q      (q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Time\t rstn en dir q");
        $monitor("%0t\t %b    %b  %b  %d",
                 $time, rstn, en, dir, q);

        // Reset
        rstn    = 0;
        en      = 0;
        dir     = 0;

        #10;

        // Release reset
        rstn = 1;

        // Count up
        en = 1;
        repeat(20) #10;

        // Hold
        en = 0;
        #20;

        dir = 1;

        // Count down
        en = 1;
        repeat(20) #10;

        $finish;
    end

endmodule