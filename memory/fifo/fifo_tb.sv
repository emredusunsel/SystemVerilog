module fifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    logic               clk, rstn, wr_en, rd_en, empty, full;
    logic [WIDTH-1:0]   data_i, data_o;

    fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .data_i (data_i),
        .wr_en  (wr_en),
        .rd_en  (rd_en),
        .data_o (data_o),
        .empty  (empty),
        .full   (full)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // ------------------------------------------------------------
    // Write task
    // ------------------------------------------------------------

    task automatic fifo_write(input logic [WIDTH-1:0] data);
        @(negedge clk);

        data_i = data;
        wr_en  = 1'b1;

        @(posedge clk);
        #1;

        wr_en = 1'b0;
    endtask

    // ------------------------------------------------------------
    // Read task
    // ------------------------------------------------------------

    task automatic fifo_read(input logic [WIDTH-1:0] expected);
        @(negedge clk);

        rd_en = 1'b1;

        @(posedge clk);
        #1;

        if (data_o !== expected) begin
            $display("FAIL: expected data_o = %h, got %h",
                        expected, data_o);
            $fatal;
        end else
            $display("PASS: read data_o = %h", data_o);

        rd_en = 1'b0;
    endtask

    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, fifo_tb);

        rstn   = 1'b0;
        data_i = '0;
        wr_en  = 1'b0;
        rd_en  = 1'b0;

        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        repeat (2) @(posedge clk);

        #1;

        if (!empty) begin
            $display("FAIL: FIFO should be empty after reset");
            $fatal;
        end

        if (full) begin
            $display("FAIL: FIFO should not be full after reset");
            $fatal;
        end

        if (data_o !== '0) begin
            $display("FAIL: data_o should be 0 after reset");
            $fatal;
        end

        $display("PASS: reset");

        rstn = 1'b1;

        // --------------------------------------------------------
        // Test 1: Write one value and read it
        // --------------------------------------------------------

        $display("");
        $display("TEST 1: Single write/read");

        fifo_write(8'hAA);

        if (empty) begin
            $display("FAIL: FIFO should not be empty");
            $fatal;
        end

        fifo_read(8'hAA);

        if (!empty) begin
            $display("FAIL: FIFO should be empty");
            $fatal;
        end

        $display("PASS: single write/read");

        // --------------------------------------------------------
        // Test 2: FIFO ordering
        // --------------------------------------------------------

        $display("");
        $display("TEST 2: FIFO ordering");

        fifo_write(8'h11);
        fifo_write(8'h22);
        fifo_write(8'h33);
        fifo_write(8'h44);

        fifo_read(8'h11);
        fifo_read(8'h22);
        fifo_read(8'h33);
        fifo_read(8'h44);

        $display("PASS: FIFO ordering");

        // --------------------------------------------------------
        // Test 3: Fill entire FIFO
        // --------------------------------------------------------

        $display("");
        $display("TEST 3: Fill FIFO");

        for (int i = 0; i < DEPTH; i++) begin
            fifo_write(i);
        end

        #1;

        if (!full) begin
            $display("FAIL: FIFO should be full");
            $fatal;
        end

        $display("PASS: FIFO full");

        // --------------------------------------------------------
        // Test 4: Write while full
        // --------------------------------------------------------

        $display("");
        $display("TEST 4: Write while full");

        @(negedge clk);

        data_i = 8'hFF;
        wr_en  = 1'b1;

        @(posedge clk);
        #1;

        wr_en = 1'b0;

        if (!full) begin
            $display("FAIL: FIFO should remain full");
            $fatal;
        end

        $display("PASS: write blocked while full");

        // --------------------------------------------------------
        // Test 5: Read all entries
        // --------------------------------------------------------

        $display("");
        $display("TEST 5: Read entire FIFO");

        for (int i = 0; i < DEPTH; i++) begin
            fifo_read(i);
        end

        if (!empty) begin
            $display("FAIL: FIFO should be empty");
            $fatal;
        end

        $display("PASS: FIFO empty");

        // --------------------------------------------------------
        // Test 6: Read while empty
        // --------------------------------------------------------

        $display("");
        $display("TEST 6: Read while empty");

        @(negedge clk);

        rd_en = 1'b1;

        @(posedge clk);
        #1;

        rd_en = 1'b0;

        if (!empty) begin
            $display("FAIL: FIFO should remain empty");
            $fatal;
        end

        $display("PASS: read blocked while empty");

        // --------------------------------------------------------
        // Test 7: Pointer wraparound
        // --------------------------------------------------------

        $display("");
        $display("TEST 7: Pointer wraparound");

        fifo_write(8'hA1);
        fifo_write(8'hA2);
        fifo_write(8'hA3);

        fifo_read(8'hA1);
        fifo_read(8'hA2);
        fifo_read(8'hA3);

        $display("PASS: pointer wraparound");

        // --------------------------------------------------------
        // Test 8: Simultaneous read/write
        // --------------------------------------------------------

        $display("");
        $display("TEST 8: Simultaneous read/write");

        fifo_write(8'h10);
        fifo_write(8'h20);
        fifo_write(8'h30);

        @(negedge clk);

        data_i = 8'h40;
        wr_en  = 1'b1;
        rd_en  = 1'b1;

        @(posedge clk);
        #1;

        if (data_o !== 8'h10) begin
            $display("FAIL: simultaneous read/write: expected 10, got %h",data_o);
            $fatal;
        end

        wr_en = 1'b0;
        rd_en = 1'b0;

        $display("PASS: simultaneous read/write");

        fifo_read(8'h20);
        fifo_read(8'h30);
        fifo_read(8'h40);

        if (!empty) begin
            $display("FAIL: FIFO should be empty");
            $fatal;
        end

        // --------------------------------------------------------
        // Done
        // --------------------------------------------------------

        $display("");
        $display("================================");
        $display("       ALL TESTS PASSED");
        $display("================================");

        $finish;

    end

endmodule
