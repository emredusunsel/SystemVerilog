`timescale 1ns/1ps

module uart_tx_tb;

    localparam int CLK_FREQ  = 10_000_000;
    localparam int BAUD_RATE = 1_000_000;
    localparam int BAUD_DIV = CLK_FREQ / BAUD_RATE;

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

    logic [7:0] expected;

    always #50 clk = ~clk;

    task automatic sample();
        int i = 0;

        #((BAUD_DIV/2)*50);
        $display("tx=%b (start bit)", tx);
        repeat (8) begin
            #((BAUD_DIV)*100);
            expected[i] = tx;
            $display("tx=%b (data bit)", tx);
            i = i + 1;
        end
        #((BAUD_DIV)*100);
        $display("tx=%b (stop bit)", tx);

        @(posedge tx_done) begin
            if (expected == data_in)
                $display("PASS: expected=%h, tx_done=%b", expected, tx_done);
        end

        $display("------------------------------------------------");

    endtask



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

        $display("------------------------------------------------");
        $display("TX started");
        $display("data = 0x%02h", data_in);
        $display("------------------------------------------------");

        // Wait for transmission to finish
        wait (tx_done == 1'b1);

        // --------------------------------
        // Test 2: Transmit 0x5A
        // --------------------------------
        @(posedge clk);
        data_in  <= 8'h5A;
        tx_start <= 1'b1;

        @(posedge clk);
        tx_start <= 1'b0;

        $display("------------------------------------------------");
        $display("TX started");
        $display("data = 0x%02h", data_in);
        $display("------------------------------------------------");

        wait (tx_done == 1'b1);

        // --------------------------------
        // Test 3: Transmit 0xFF
        // --------------------------------
        @(posedge clk);
        data_in  <= 8'hFF;
        tx_start <= 1'b1;

        @(posedge clk);
        tx_start <= 1'b0;

        $display("------------------------------------------------");
        $display("TX started");
        $display("data = 0x%02h", data_in);
        $display("------------------------------------------------");

        wait (tx_done == 1'b1);

        #500;

        $finish;
    end

    // Monitor important signals
    //initial begin
    //    $monitor(
    //        "time=%0t | rstn=%b | data=%h | tx_start=%b | tx=%b | busy=%b | done=%b",
    //        $time,
    //        rstn,
    //        data_in,
    //        tx_start,
    //        tx,
    //        tx_busy,
    //        tx_done
    //    );
    //end

    initial begin
        repeat (4) begin
            @(posedge tx_start)
                sample();
        end
    end

endmodule
