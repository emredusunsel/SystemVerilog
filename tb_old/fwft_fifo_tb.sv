`timescale 1ps/1ps

module fwft_fifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    localparam int PTR_WIDTH    = $clog2(DEPTH);
    localparam int ADDR_WIDTH   = PTR_WIDTH - 1;

    logic clk, rstn, wr_en;
    logic [WIDTH-1:0] wr_data;
    logic rd_en;
    logic [WIDTH-1:0] rd_data;
    logic full, empty;

    fwft_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk        (clk),
        .rstn       (rstn),
        .wr_en      (wr_en),
        .wr_data    (wr_data),
        .rd_en      (rd_en),
        .rd_data    (rd_data),
        .full       (full),
        .empty      (empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn    = 0;
        wr_data = '0;
        wr_en   = 0;
        rd_en   = 0;
    end

    ////////////////////////////
    // RESET TEST
    ////////////////////////////

    task automatic reset_test();
        $display("TEST 1: Reset");
        
        rstn = 0;
        @(posedge clk);
        if (!(empty && !full))
            $fatal(1, "FAIL: expected empty && !full when rstn=0");

        #1;
        rstn = 1;
        @(posedge clk);
        if (!(empty && !full))
            $fatal(1, "FAIL: expected empty && !full when rstn=1");
        else
            $display("TEST 1: PASSED");
    endtask

    ////////////////////////////
    // FIRST WRITE INTO EMPTY FIFO TEST
    ////////////////////////////

    task automatic first_wr_test();
        $display("TEST 2: First Write");

        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'hA5;

        @(posedge clk);
        #1;
        if (!((!empty && !full) && (rd_data == 8'hA5)))
            $fatal(1, "FAIL: expected rd_data=a5 e=0 f=0 | got rd_data=%0h e=%0d f=%0d",
                    rd_data,
                    empty,
                    full);
        else
            $display("TEST 2: PASSED");

        wr_en = 0;
    endtask

    ////////////////////////////
    // DATA STABILITY WHEN NOT READING TEST
    ////////////////////////////

    task automatic data_stability_test();
        $display("TEST 3: Data Stability when rd_en = 0");
        wr_en = 0;
        rd_en = 0;

        #1;
        if (!((!empty && !full) && (rd_data == 8'hA5)))
            $fatal(1, "FAIL: expected rd_data=a5 e=0 f=0 | got rd_data=%0h e=%0d f=%0d",
                    rd_data,
                    empty,
                    full);

        repeat (20) begin
            @(posedge clk);
            if (!((!empty && !full) && (rd_data == 8'hA5)))
                $fatal(1, "FAIL: expected rd_data=a5 e=0 f=0 | got rd_data=%0h e=%0d f=%0d",
                        rd_data,
                        empty,
                        full);
        end

        $display("TEST 3: PASSED");
    endtask

    ////////////////////////////
    // SINGLE READ TEST
    ////////////////////////////

    task automatic single_read_test();
        $display("TEST 4: Single Read");
        
        @(negedge clk);
        rd_en = 1;
        wr_en = 0;
        @(posedge clk);
        #1;

        if (empty && (rd_data === 8'hA5)) begin
            $display("TEST 4: PASSED");
        end else
            $fatal(1, "FAIL: rd_data=%0h (expected=a5) e=%0d (expected=1)",
                    rd_data,
                    empty);
        rd_en = 0;
    endtask

    ////////////////////////////
    // MULTIPLE WRITE/READ TEST
    ////////////////////////////

    task automatic multi_wr_rd_test();
        $display("TEST 5: Multiple Writes/FIFO Order");

        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'hA1;
        @(negedge clk);
        wr_data = 8'hB2;
        @(negedge clk);
        wr_data = 8'hC3;
        @(negedge clk);
        wr_data = 8'hD4;

        @(posedge clk);
        #1;
        wr_en   = 0;

        if (!(!empty && (rd_data === 8'hA1)))
            $fatal(1, "FAIL: Unexpected rd_data|empty");

        @(negedge clk);
        rd_en = 1;
        @(posedge clk);
        #1;
        if (rd_data !== 8'hB2)
            $fatal(1, "FAIL: Excpected B2");
        
        @(posedge clk);
        #1;
        if (rd_data !== 8'hC3)
            $fatal(1, "FAIL: Expected C3");

        @(posedge clk);
        #1;
        if (empty || (rd_data !== 8'hD4))
            $fatal(1, "FAIL: Expected D4 or empty=0");

        @(posedge clk);
        #1;
        if (!empty || (rd_data !== 8'hD4))
            $fatal(1, "FAIL: Expected D4 or empty=1");
        
        @(posedge clk);
        #1;
        rd_en = 0;

        $display("TEST 5: PASSED");
    endtask

    ////////////////////////////
    // OUTPUT CHANGE ONLY AFTER CONSUMPTION
    ////////////////////////////

    task automatic consume_test();
        $display("TEST 6: Output Change Only After Consumption");

        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'hA1;
        @(negedge clk);
        wr_data = 8'hB2;
        @(negedge clk);
        wr_data = 8'hC3;
        @(posedge clk);
        #1;
        wr_en = 0;

        if (rd_data !== 8'hA1)
            $fatal(1, "FAIL: Unexpected output");
        
        @(negedge clk);
        rd_en = 1;
        @(posedge clk);
        #1;
        rd_en = 0;

        if (rd_data !== 8'hB2)
            $fatal(1, "FAIL: Unexpected output");

        repeat (20) begin
            @(posedge clk);
            #1;
            if (rd_data !== 8'hB2)
                $fatal(1, "FAIL: Unexpected output");
        end

        $display("TEST 6: PASSED");
    endtask

    ////////////////////////////
    // READ WHILE EMPTY
    ////////////////////////////

    task automatic empty_read_test();
        $display("TEST 7: Read While Empty");
        
        rd_en = 0;
        wr_en = 0;

        repeat (DEPTH + 1) begin
            @(negedge clk);
            rd_en = 1;
        end
        @(negedge clk);
        rd_en = 0;

        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        if (empty) begin
            @(negedge clk);
            rd_en = 1;
            @(posedge clk);
            #1;
        end else
            $fatal(1, "FAIL: FIFO should be empty");

        $display("TEST 7: PASSED");
    endtask

    ////////////////////////////
    // FILL FIFO
    ////////////////////////////

    task automatic fill_fifo_test();
        $display("TEST 8: Fill FIFO");

        wr_en = 0;

        if (!empty) begin
            repeat(DEPTH + 1) begin
                @(negedge clk);
                rd_en = 1;
            end
        end

        rd_en = 0;

        @(negedge clk);
        wr_en = 1;
        for (int i = 0; i < DEPTH; i++) begin
            wr_data = i;
            @(negedge clk);
        end
        @(negedge clk);
        wr_en = 0;

        if (!full)
            $fatal(1, "FAIL: expected full");
        if (rd_data !== '0)
            $fatal(1, "FAIL: wrong output");

        @(negedge clk);
        rd_en = 1;
        @(posedge clk);
        #1;
        if (rd_data !== 8'h01)
            $fatal(1, "FAIL: wrong output");
        if (full)
            $fatal(1, "FAIL: full should be 0");
        rd_en = 0;

        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'h0E;
        @(posedge clk);
        #1;
        wr_en   = 0;
        if (!full)
            $fatal(1, "FAIL: Exptected full");
        if (rd_data !== 8'h01)
            $fatal(1, "FAIL: rd_data shouldnt change");
        if (dut.mem[dut.rd_ptr - 1'b1] !== 8'h0E)
            $fatal(1, "FAIL: expected write accept");

        $display("TEST 8: PASSED");
    endtask

    ////////////////////////////
    // FULL + SIMULTANEOUS READ/WRITE
    ////////////////////////////

    task automatic full_wr_rd_test();
        logic [WIDTH-1:0] first_word, second_word;

        $display("TEST 9: Simultaneous Read/Write while FULL");

        wr_en = 0;
        rd_en = 0;

        if (!full) begin
            for (int i = 0; i < 0; i++) begin
                @(negedge clk);
                wr_en   = 1;
                wr_data = i;
            end
        end

        @(negedge clk);
        wr_en = 0;

        if (!full)
            $fatal(1, "FAIL: FIFO not full");
        
        first_word = dut.mem[dut.rd_ptr];
        second_word = dut.mem[dut.rd_ptr + 1'b1];
        #1;
        if (rd_data !== first_word) 
            $fatal(1, "FAIL: ---------");

        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        wr_data = 8'h0E;
        @(negedge clk);
        wr_en = 0;
        rd_en = 0;
        @(posedge clk);
        #1;

        if (rd_data === first_word)
            $fatal(1, "FAIL: Unexpected output");
        if (rd_data !== second_word)
            $fatal(1, "FAIL: Unexpected output");
        if (dut.mem[dut.rd_ptr - 1'b1] !== 8'h0E)
            $fatal(1, "FAIL: 0E should be write accepted");
        if (!full)
            $fatal(1, "FAIL: full was expected");
        
        $display("TEST 9: PASSED");
    endtask

    ////////////////////////////
    // EMPTY + SIMULTANEOUS READ/WRITE
    ////////////////////////////

    task automatic empty_wr_rd_test();
        $display("TEST 10: Simultaneous Read/Write while EMPTY");

        if (!empty) begin
            rd_en = 1;
            repeat (DEPTH + 1) begin
                @(negedge clk);
            end
        end

        rd_en = 0;
        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        @(negedge clk);
        wr_data = 8'h0A;
        wr_en   = 1;
        rd_en   = 1;
        @(posedge clk);
        #1;

        if (rd_data !== 8'h0A)
            $fatal(1, "FAIL: expected 0a got %0h", rd_data);
        if (empty)
            $fatal(1, "FAIL: should not be empty");
        wr_en = 0;
        @(posedge clk);
        #1;
        if (rd_data !== 8'h0A)
            $fatal(1, "FAIL: should stay 0a");
        if (!empty)
            $fatal(1, "FAIL: should be empty");
        rd_en = 0;

        $display("TEST 10: PASSED");
    endtask

    ////////////////////////////
    // PARTIALLY FULL + SIMULTANEOUS READ/WRITE
    ////////////////////////////

    task automatic simultaneous_wr_rd_test();
        $display("TEST 11: Partially Full Simultaneous Read/Write");
        
        wr_en = 0;
        rd_en = 0;

        if (!empty) begin
            rd_en = 1;
            repeat (DEPTH + 1) begin
                @(negedge clk);
            end
        end
    
        @(negedge clk);
        rd_en   = 0;
        wr_en   = 1;
        wr_data = 8'h0A;
        @(negedge clk);
        wr_data = 8'h0B;
        @(negedge clk);
        wr_data = 8'h0C;
        @(posedge clk);
        #1;
        wr_en = 0;

        if (rd_data !== 8'h0A)
            $fatal(1, "FAIL: Wrong output");

        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        wr_data = 8'h0D;
        @(posedge clk); 
        #1;
        if ((rd_data !== 8'h0B) || (dut.mem[dut.rd_ptr[ADDR_WIDTH:0] + 2'd2] !== 8'h0D))
            $fatal(1, "FAIL: Output failed OR new data not inserted");
            
        @(negedge clk);
        wr_data = 8'h0E;
        @(posedge clk);
        #1;
        if ((rd_data !== 8'h0C) || (dut.mem[dut.rd_ptr[ADDR_WIDTH:0] + 2'd2] !== 8'h0E))
            $fatal(1, "FAIL: Output failed OR new data not inserted");

        @(negedge clk);
        wr_data = 8'h0F;
        @(posedge clk);
        #1;
        if ((rd_data !== 8'h0D) || (dut.mem[dut.rd_ptr[ADDR_WIDTH:0] + 2'd2] !== 8'h0F))
            $fatal(1, "FAIL: Output failed OR new data not inserted");
        
        wr_en = 0;
        rd_en = 0;

        $display("TEST 11: PASSED");
    endtask

    ////////////////////////////
    // WRITE WHILE FULL
    ////////////////////////////

    task automatic write_full_test();
        $display("TEST 12: Write while FIFO full");

        rd_en = 0;
        wr_en = 0;

        repeat (DEPTH + 1) begin
            @(negedge clk);
            rd_en = 1;
        end
        @(negedge clk);
        rd_en = 0;

        if (!full) begin
            repeat (DEPTH + 1) begin
                @(negedge clk);
                wr_en = 1;
                wr_data = '0;
            end
        end
        @(negedge clk);
        wr_en = 0;

        if (!full)
            $fatal(1 ,"FAIL: not full");

        @(negedge clk);
        wr_en = 1;
        wr_data = 8'h0A;
        @(posedge clk);
        wr_en = 0;

        if (rd_data !== '0)
            $fatal(1, "FAIL: %0h expected '0 at output", rd_data);

        for (int i = 0; i < DEPTH; i++) begin
            if (dut.mem[i] === 8'h0A)
                $fatal(1, "FAIL: mem[%d] = 0A while it should be '0", i);
        end

        if (!full)
            $fatal(1 ,"FAIL: not full");

        $display("TEST 12: PASSED");
    endtask

    ////////////////////////////
    // POINTER WRAPAROUND
    ////////////////////////////

    task automatic ptr_wraparound_test();
        $display("TEST 13: Pointer Wraparound");

        rd_en = 0;
        wr_en = 0;

        repeat (DEPTH + 1) begin
            @(negedge clk);
            rd_en = 1;
        end

        @(negedge clk);
        rd_en = 0;
        wr_en = 1;
        
        for (int i = 0; i < DEPTH; i++) begin
            wr_data = i;
            @(negedge clk);
        end
        wr_en = 0;
        rd_en = 1;

        for (int j = 0; j < DEPTH/2; j++) begin
            if (rd_data !== j)
                $fatal(1, "FAIL: %0h %0d", rd_data, j);
            @(negedge clk);
        end
        rd_en = 0;
        wr_en = 1;

        for (int k = 0; k < DEPTH/2; k++) begin
            wr_data = DEPTH + k;
            @(negedge clk);
        end
        wr_en = 0;
        rd_en = 1;

        for (int m = DEPTH/2; m < DEPTH; m++) begin
            if (rd_data !== m)
                $fatal(1, "FAIL: %0h %0d", rd_data, m);
            @(negedge clk);
        end
        rd_en = 0;
        wr_en = 0;

        // THIS SHOULD BE DONE SEVERAL MORE TIMES
        // FIND A COMPACT SOLUTION

        $display("TEST 13: PASSED");
    endtask

    task automatic write_fifo(logic [WIDTH-1:0] data);
        @(negedge clk);
        wr_en   = 1;
        wr_data = data;
        @(negedge clk);
        wr_en   = 0;
    endtask

    task automatic read_fifo();
        @(negedge clk);
        rd_en = 1;
        @(negedge clk);
        rd_en = 0;
    endtask

    initial begin
        reset_test();
        #1;
        first_wr_test();
        #1;
        data_stability_test();
        #1;
        single_read_test();
        #1;
        multi_wr_rd_test();
        #1;
        consume_test();
        #1;
        empty_read_test();
        #1;
        fill_fifo_test();
        #1;
        full_wr_rd_test();
        #1;
        empty_wr_rd_test();
        #1;
        simultaneous_wr_rd_test();
        #1;
        write_full_test();
        #1;
        ptr_wraparound_test();
        #1;

        $display("========================");
        $display("  ALL TESTS ARE PASSED");
        $display("========================");

        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fwft_fifo_tb);
    end

endmodule
