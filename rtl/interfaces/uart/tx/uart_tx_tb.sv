`timescale 1ns/1ps

module uart_tx_tb;

    localparam int CLK_FREQ  = 10_000_000;
    localparam int BAUD_RATE = 1_000_000;

    logic clk, rstn;
    logic [7:0] data_in;
    logic tx_start, tx, tx_busy, tx_done;

    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk       (clk),
        .rstn      (rstn),

        .data_in   (data_in),
        .tx_start  (tx_start),

        .tx        (tx),
        .tx_busy   (tx_busy),
        .tx_done   (tx_done)
    );

    // 10 MHz clock -> 100 ns period
    always #50 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tx_tb);
        
        clk       = 1'b0;
        rstn      = 1'b0;
        data_in   = 8'h00;
        tx_start  = 1'b0;

        // Reset
        #200;
        rstn = 1'b1;

        // --------------------------------
        // Test 1: Transmit 0xA5
        // --------------------------------
        @(posedge clk);
        data_in  <= 8'hA5;
        tx_start <= 1'b1;

        @(posedge clk);
        tx_start <= 1'b0;

        // Wait until transmission starts
        wait (tx_busy == 1'b1);

        $display("------------------------------------------------");
        $display("TX started");
        $display("data = 0x%02h", data_in);
        $display("------------------------------------------------");

        // Wait for transmission to finish
        wait (tx_done == 1'b1);

        $display("TX done");
        $display("------------------------------------------------");

        // --------------------------------
        // Test 2: Transmit 0x5A
        // --------------------------------
        @(posedge clk);
        data_in  <= 8'h5A;
        tx_start <= 1'b1;

        @(posedge clk);
        tx_start <= 1'b0;

        wait (tx_done == 1'b1);

        $display("TX done for 0x5A");
        $display("------------------------------------------------");

        // --------------------------------
        // Test 3: Transmit 0xFF
        // --------------------------------
        @(posedge clk);
        data_in  <= 8'hFF;
        tx_start <= 1'b1;

        @(posedge clk);
        tx_start <= 1'b0;

        wait (tx_done == 1'b1);

        $display("TX done for 0xFF");
        $display("------------------------------------------------");

        #500;

        $finish;
    end

    // Monitor important signals
    initial begin
        $monitor(
            "time=%0t | rstn=%b | data=%h | tx_start=%b | tx=%b | busy=%b | done=%b",
            $time,
            rstn,
            data_in,
            tx_start,
            tx,
            tx_busy,
            tx_done
        );
    end

endmodule
