`timescale 1ps/1ps

module grey_counter_tb;

    localparam WIDTH = 4;

    logic clk, rstn;
    logic [WIDTH-1:0] q;

    grey_counter dut(
        .clk(clk),
        .rstn(rstn),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Print values whenever they change
        $display("Time\t  bcd q");
        $monitor("%0t\t %b %b", $time, dut.bcd_count, q);

        rstn = 1;
        repeat(16) #10;
        
        $finish;

    end

endmodule
