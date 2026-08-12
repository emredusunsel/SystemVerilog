`timescale 1ns/1ps

module uart_tb;

    localparam int CLK_FREQ  = 10_000_000;
    localparam int BAUD_RATE = 1_000_000;
    localparam int BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    logic       clk;
    logic       rstn;

    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx;
    logic       tx_busy;
    logic       tx_done;

    logic       rx;
    logic [7:0] rx_data;
    logic       rx_valid;


    // --------------------------------
    // DUT
    // --------------------------------

    uart #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) dut (
        .clk       (clk),
        .rstn      (rstn),

        .tx_data   (tx_data),
        .tx_start  (tx_start),
        .tx        (tx),
        .tx_busy   (tx_busy),
        .tx_done   (tx_done),

        .rx        (rx),
        .rx_data   (rx_data),
        .rx_valid  (rx_valid)
    );


    // --------------------------------
    // UART loopback
    // --------------------------------

    assign rx = tx;


    // --------------------------------
    // Clock
    // --------------------------------

    always #50 clk = ~clk;


    // --------------------------------
    // RX checker
    // --------------------------------

    always @(posedge clk) begin
        if (rx_valid) begin
            $display(
                "RX VALID | time=%0t | RX_DATA=%h",
                $time,
                rx_data
            );
        end
    end


    // --------------------------------
    // Send byte
    // --------------------------------

    task send_byte(input logic [7:0] data);
        begin

            tx_data = data;

            @(posedge clk);
            tx_start = 1'b1;

            @(posedge clk);
            tx_start = 1'b0;

            // Wait for complete UART frame
            repeat (10 * BAUD_DIV + 20)
                @(posedge clk);

        end
    endtask


    // --------------------------------
    // Test
    // --------------------------------

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, uart_tb);

        clk      = 1'b0;
        rstn     = 1'b0;

        tx_data  = 8'h00;
        tx_start = 1'b0;


        // Reset
        #200;
        rstn = 1'b1;

        repeat (10)
            @(posedge clk);


        // --------------------------------
        // Test 1
        // --------------------------------

        $display("");
        $display("Sending 0xA5");

        send_byte(8'hA5);


        // --------------------------------
        // Test 2
        // --------------------------------

        $display("");
        $display("Sending 0x5A");

        send_byte(8'h5A);


        // --------------------------------
        // Test 3
        // --------------------------------

        $display("");
        $display("Sending 0xFF");

        send_byte(8'hFF);


        // --------------------------------
        // Test 4
        // --------------------------------

        $display("");
        $display("Sending 0x00");

        send_byte(8'h00);


        // --------------------------------
        // Finish
        // --------------------------------

        $display("");
        $display("--------------------------------");
        $display("UART TESTBENCH FINISHED");
        $display("--------------------------------");

        #500;

        $finish;

    end


    // --------------------------------
    // General monitor
    // --------------------------------

    initial begin
        $monitor(
            "time=%0t | tx_data=%h | tx_start=%b | tx=%b | tx_busy=%b | tx_done=%b | rx_data=%h | rx_valid=%b",
            $time,
            tx_data,
            tx_start,
            tx,
            tx_busy,
            tx_done,
            rx_data,
            rx_valid
        );
    end

endmodule
