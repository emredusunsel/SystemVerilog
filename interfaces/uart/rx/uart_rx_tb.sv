`timescale 1ns/1ps

module uart_rx_tb;

    localparam int CLK_FREQ  = 10_000_000;
    localparam int BAUD_RATE = 1_000_000;
    localparam int BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    logic       clk;
    logic       rstn;

    logic       rx;

    logic [7:0] data_out;
    logic       rx_valid;


    // --------------------------------
    // DUT
    // --------------------------------

    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk       (clk),
        .rstn      (rstn),

        .rx        (rx),

        .data_out  (data_out),
        .rx_valid  (rx_valid)
    );


    // --------------------------------
    // Clock
    // --------------------------------

    // 10 MHz clock = 100 ns period
    always #50 clk = ~clk;


    // --------------------------------
    // Send one UART bit
    // --------------------------------

    task send_bit(input logic bit_value);
        begin
            rx = bit_value;

            repeat (BAUD_DIV)
                @(posedge clk);
        end
    endtask


    // --------------------------------
    // Send one UART byte
    // --------------------------------

    task send_byte(input logic [7:0] data);
        begin

            // Start bit
            send_bit(1'b0);

            // Data bits - LSB first
            send_bit(data[0]);
            send_bit(data[1]);
            send_bit(data[2]);
            send_bit(data[3]);
            send_bit(data[4]);
            send_bit(data[5]);
            send_bit(data[6]);
            send_bit(data[7]);

            // Stop bit
            rx = 1'b1;

            // Keep stop bit high until RX finishes
            wait (rx_valid == 1'b1);

            // Return to idle
            rx = 1'b1;

        end
    endtask


    // --------------------------------
    // Test
    // --------------------------------

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, uart_rx_tb);

        clk = 1'b0;
        rstn = 1'b0;
        rx = 1'b1;

        // Reset
        #200;
        rstn = 1'b1;


        // --------------------------------
        // Test 1: 0xA5
        // --------------------------------

        send_byte(8'hA5);

        if (data_out == 8'hA5)
            $display("PASS: Received 0x%02h", data_out);
        else
            $display("FAIL: Expected 0xA5, received 0x%02h", data_out);


        // Wait for rx_valid to go low
        @(posedge clk);


        // --------------------------------
        // Test 2: 0x5A
        // --------------------------------

        send_byte(8'h5A);

        if (data_out == 8'h5A)
            $display("PASS: Received 0x%02h", data_out);
        else
            $display("FAIL: Expected 0x5A, received 0x%02h", data_out);


        @(posedge clk);


        // --------------------------------
        // Test 3: 0xFF
        // --------------------------------

        send_byte(8'hFF);

        if (data_out == 8'hFF)
            $display("PASS: Received 0x%02h", data_out);
        else
            $display("FAIL: Expected 0xFF, received 0x%02h", data_out);


        @(posedge clk);


        // --------------------------------
        // Test 4: 0x00
        // --------------------------------

        send_byte(8'h00);

        if (data_out == 8'h00)
            $display("PASS: Received 0x%02h", data_out);
        else
            $display("FAIL: Expected 0x00, received 0x%02h", data_out);


        // --------------------------------
        // Finish
        // --------------------------------

        #500;

        $display("--------------------------------");
        $display("UART RX TESTBENCH FINISHED");
        $display("--------------------------------");

        $finish;

    end


    // --------------------------------
    // Monitor
    // --------------------------------

    initial begin
        $monitor(
            "time=%0t | rx=%b | data_out=%h | rx_valid=%b",
            $time,
            rx,
            data_out,
            rx_valid
        );
    end

endmodule