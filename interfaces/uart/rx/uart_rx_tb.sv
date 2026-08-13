`timescale 1ns/1ps

module uart_rx_tb;

    localparam int CLK_FREQ  = 10_000_000;
    localparam int BAUD_RATE = 1_000_000;
    localparam int BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    logic clk, rstn, rx;
    logic [7:0] data_out;
    logic rx_valid;

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

    always #50 clk = ~clk;

    task send_bit(input logic bit_value);
        begin
            rx = bit_value;

            repeat (BAUD_DIV)
                @(posedge clk);
        end
    endtask

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
            send_bit(1'b1);

            // Idle
            rx = 1'b1;
        end
    endtask

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, uart_rx_tb);

        clk = 1'b0;
        rstn = 1'b0;
        rx = 1'b1;

        #200;
        rstn = 1'b1;

        // --------------------------------
        // Test 1
        // --------------------------------

        $display("Sending 0xA5...");
        send_byte(8'hA5);

        // --------------------------------
        // Test 2
        // --------------------------------

        $display("Sending 0x5A...");
        send_byte(8'h5A);

        // --------------------------------
        // Test 3
        // --------------------------------

        $display("Sending 0xFF...");
        send_byte(8'hFF);

        // --------------------------------
        // Test 4
        // --------------------------------

        $display("Sending 0x00...");
        send_byte(8'h00);

        $display("--------------------------------");
        $display("UART RX TESTBENCH FINISHED");
        $display("--------------------------------");

        #500;

        $finish;

    end


    // --------------------------------
    // Monitor
    // --------------------------------

    //initial begin
    //    $monitor(
    //        "time=%0t | rx=%b | data_out=%h | rx_valid=%b",
    //        $time,
    //        rx,
    //        data_out,
    //        rx_valid
    //    );
    //end

    initial begin
        repeat(4) begin
            @(posedge rx_valid)
                $display("-----------@posedge rx_valid Data=%h-----------", data_out);
        end
    end

endmodule