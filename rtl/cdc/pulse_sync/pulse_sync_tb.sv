`timescale 1ns/1ps

module pulse_sync_tb;

    logic clk_src, clk_dst, rstn, pulse_src, pulse_dst;

    pulse_sync dut (
        .clk_src   (clk_src),
        .clk_dst   (clk_dst),
        .rstn      (rstn),
        .pulse_src (pulse_src),
        .pulse_dst (pulse_dst)
    );

    always #5 clk_src = ~clk_src;
    always #7 clk_dst = ~clk_dst;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, pulse_sync_tb);

        clk_src   = 0;
        clk_dst   = 0;
        rstn      = 0;
        pulse_src = 0;

        // Reset
        #12;
        rstn = 1;

        // Pulse 1
        #13;
        pulse_src = 1;
        #10;
        pulse_src = 0;

        // Pulse 2
        #30;
        pulse_src = 1;
        #10;
        pulse_src = 0;

        // Pulse 3
        #30;
        pulse_src = 1;
        #10;
        pulse_src = 0;

        #50;

        $finish;
    end

    initial begin
        $monitor(
            "time=%0t | rstn=%b | pulse_src=%b | toggle_src=%b | sync_ff1=%b | sync_ff2=%b | pulse_dst=%b",
            $time,
            rstn,
            pulse_src,
            dut.toggle_src,
            dut.sync_ff1,
            dut.sync_ff2,
            pulse_dst
        );
    end

endmodule
