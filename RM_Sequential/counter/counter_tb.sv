`timescale 1ps/1ps

module counter_tb;

    localparam int WIDTH = 4;

    logic             clk, rstn, en;
    logic [WIDTH-1:0] q;

    counter #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .en(en),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Time\t rstn en q");
        $monitor("%0t\t %b    %b  %d",
                 $time, rstn, en, q);

        // Reset
        rstn = 0;
        en   = 0;

        #10;

        // Release reset
        rstn = 1;

        // Count
        en = 1;
        #200;

        // Hold
        en = 0;
        #20;

        $finish;
    end

endmodule