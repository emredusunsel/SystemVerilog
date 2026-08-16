`timescale 1ps/1ps

module spram_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    logic clk, rstn, en, we;
    logic [$clog2(DEPTH)-1:0] addr;
    logic [     WIDTH-1:0] wr_data, rd_data;

    spram # (
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .en     (en),
        .we     (we),
        .addr   (addr),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn    = 0;
        en      = 0;
        we      = 0;
        addr    = '0;
    end


    ///////////////////////
    // RESET
    //////////////////////

    task automatic reset_test();
        $display("TEST 1: RESET");
        rstn = 0;
        @(posedge clk); #1;

        if (rd_data !== '0)
            $fatal(1, "FAIL: rd_data=%0h on reset",rd_data);

        @(negedge clk);
        rstn = 1;

        if (rd_data !== '0)
            $fatal(1, "FAIL: rd_data=%0h after reset",rd_data);

        $display("TEST 1: PASSED");
    endtask

    ///////////////////////
    // BASIC WRITE/READ
    //////////////////////

    task automatic basic_wr_rd_test();
        $display("TEST 2: Basic Write/Read");

        // Write
        for (int i = 0; i < 4; i++) begin
            we      = 1;
            en      = 1;
            addr    = i;
            wr_data = {4'(i), 4'(i)};
            @(negedge clk);
        end
        we = 0;
    
        // Read
        for (int i = 0; i < 4; i++) begin
            en      = 1;
            addr    = i;
            @(negedge clk);
            @(posedge clk); #1;
            if (rd_data !== {4'(i), 4'(i)})
                $fatal(1, "FAIL: expected=%0h on addr=%0d",
                        dut.mem[addr[i]],
                        i);
        end
        en = 0;

        $display("TEST 2: PASSED");
    endtask

    ///////////////////////
    // MULTIPLE ADDRESSES
    //////////////////////

    task automatic multi_addr_test();
        $display("TEST 3: Multiple Addresses");

        for (int i = 0; i < DEPTH; i++) begin
            we      = 1;
            en      = 1;
            addr    = i;
            wr_data = i;
            @(negedge clk);
        end
        we = 0;

        for (int i = 0; i < DEPTH; i++) begin
            en      = 1;
            addr    = i;
            @(negedge clk);
            @(posedge clk); #1;
            if (rd_data != i) 
                $fatal(1, "FAIL: expected=%0h on addr=%0d",
                        dut.mem[addr[i]],
                        i);
        end
        en = 0;

        $display("TEST 3: PASSED");
    endtask

    ///////////////////////
    // REPEATED WRITES
    //////////////////////

    task automatic repeated_write_test();
        $display("TEST 4: Repeated Writes");

        for (int i = 0; i < 10; i++) begin
            we      = 1;
            en      = 1;
            addr    = 0;
            wr_data = $urandom;
            @(negedge clk);
        end
        wr_data = 8'hAA;
        @(negedge clk);
        we = 0;
        @(posedge clk); #1;

        if (rd_data != 8'hAA)
            $fatal(1, "FAIL: expected rd_data=aa, got rd_data=%0h", rd_data);


        $display("TEST 4: PASSED");
    endtask

    ///////////////////////
    // ENABLE DISABLED
    //////////////////////

    task automatic en_disabled_test();
        $display("TEST 5: Enable Disabled");
        @(negedge clk);
        en      = 1;
        we      = 1;
        addr    = 1;
        wr_data = 8'hBB;
        @(negedge clk);
        en = 0;
        we = 0;

        // Write attempts
        for (int i = 0; i < 4; i++) begin
            if (dut.mem[1] !== 8'hBB)
                $fatal(1, "FAIL: mem contents changed");
            @(negedge clk);
            we      = 1;
            wr_data = i;
        end
        we = 0;

        en = 1;
        @(posedge clk); #1;
        if (rd_data !== 8'hBB)
            $fatal(1, "FAIL: expected rd_data=bb, got rd_data=%0h", rd_data);

        $display("TEST 5: PASSED");
    endtask

    ///////////////////////
    // BACK TO BACK OPERATIONS
    //////////////////////

    task automatic b2b_wr_rd_test(int i);
        $display("TEST 6: Back-to-Back Write Read");
        
        @(negedge clk);
        we = 0;
        en = 0;
        wr_data = '0;
        addr = '0;

        for (int j = 0; j < i; j++) begin
            @(negedge clk);
            we = 1;
            en = 1;
            wr_data = j;
            addr = j;
            @(negedge clk);
            we = 0;
            @(posedge clk); #1;
            if (rd_data !== j)
                $fatal(1, "FAIL: unexpected output %0h at turn %0d", rd_data, j);
        end
        en = 0;
        addr = '0;
        wr_data = '0;

        $display("TEST 6: PASSED");
    endtask

    initial begin
        reset_test();           #1;
        basic_wr_rd_test();     #1;
        multi_addr_test();      #1;
        repeated_write_test();  #1;
        en_disabled_test();     #1;
        b2b_wr_rd_test(40);     #1;

        #10;
        $display("===========================");
        $display("     ALL TESTS PASSED");
        $display("===========================");
        
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, spram_tb);
    end

endmodule
