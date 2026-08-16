`timescale 1ps/1ps

module dpram_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    logic clk, rstn, wr_en;
    logic [$clog2(DEPTH)-1:0] wr_addr;
    logic [WIDTH-1:0] wr_data;
    logic rd_en;
    logic [$clog2(DEPTH)-1:0] rd_addr;
    logic [WIDTH-1:0] rd_data;

    dpram # (
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .wr_en  (wr_en),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_en  (rd_en),
        .rd_addr(rd_addr),
        .rd_data(rd_data)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn    = 0;
        wr_en   = 0;
        wr_data = '0;
        wr_addr = '0;
        rd_en   = 0;
        rd_addr = '0;
    end

    ////////////////////////
    // RESET
    ////////////////////////

    task automatic reset_test();
        $display("TEST 1: Reset");
        rstn = 0;
        @(posedge clk); #1;
        if (rd_data != '0)
            $fatal(1, "FAIL: exptected '0 at output while reset 0");
        @(negedge clk);
        rstn    = 1;
        wr_en   = 0;
        wr_data = '0;
        wr_addr = '0;
        rd_en   = 0;
        rd_addr = 0;
        @(posedge clk); #1;
        if (rd_addr != '0)
            $fatal(1, "FAIL: expected '0 at output after reset");

        $display("TEST 1: PASSED");
    endtask

    ////////////////////////
    // READ WRITE
    ////////////////////////

    task automatic wr_re_test();
        $display("TEST 2: Basic Read Write Test");
        
        @(negedge clk);
        wr_en = 1;
        for (int i = 0; i < 4; i++) begin
            wr_addr = i;
            wr_data = {4'(i), 4'(i)};
            @(negedge clk);
        end
        wr_en = 0;
        
        @(negedge clk);
        rd_en = 1;
        for (int i = 0; i < 4; i++) begin
            rd_addr = i;
            @(negedge clk);
            if (rd_data != {4'(i), 4'(i)})
                $fatal(1, "FAIL: expected=%0h, got=%0h",
                        {4'(i), 4'(i)},
                        rd_data);
        end
        rd_en = 0;

        $display("TEST 2: PASSED");
    endtask

    ////////////////////////
    // MULTIPLE ADDRESSES
    ////////////////////////

    task automatic multi_addr_test();
        $display("TEST 3: Multiple Addresses");

        @(negedge clk);
        wr_en = 1;
        for (int i = 0; i < DEPTH; i++) begin
            wr_addr = i;
            wr_data = i;
            @(negedge clk);
        end
        wr_en = 0;

        @(negedge clk);
        rd_en = 1;
        for (int i = 0; i < DEPTH; i++) begin
            rd_addr = i;
            @(negedge clk);
            if (rd_data != i)
                $fatal(1, "FAIL: expected=%0h got=%0h",
                        i,
                        rd_data);
        end
        rd_en = 0;

        $display("TEST 3: PASSED");
    endtask

    ////////////////////////
    // REPEATED WRITES
    ////////////////////////

    task automatic repeated_wr_test();
        $display("TEST 4: Repeated Writes");

        @(negedge clk);
        wr_en   = 1;
        wr_addr = DEPTH/2;
        for (int i = 0; i < 4; i++) begin
            wr_data = i*2;
            @(negedge clk);
        end
        wr_en = 0;

        rd_en = 1;
        rd_addr = DEPTH/2;
        @(posedge clk); #1;
        if (rd_data != 8'd6)
            $fatal(1, "FAIL: expected=6 got=%0h", rd_data);
        rd_en = 0;

        $display("TEST 4: PASSED");
    endtask

    ////////////////////////
    // ENABLE DISABLED
    ////////////////////////

    task automatic enable_low_test();
        $display("TEST 5: Enable Disabled");

        @(negedge clk);
        rd_en   = 0;
        wr_en   = 1;
        wr_addr = 0;
        wr_data = 8'hAA;
        @(negedge clk);
        wr_en   = 0;
        wr_data = 8'hBB;
        @(negedge clk);
        wr_data = 8'hCC;
        @(negedge clk);
        wr_data = 8'hDD;
        @(negedge clk);
        if (dut.mem[wr_addr] != 8'hAA)
            $fatal(1, "FAIL: mem changed to %0h", dut.mem[wr_addr]);

        @(negedge clk);
        wr_addr = 1;
        wr_data = 8'hEE;
        wr_en   = 1;
        @(negedge clk);
        rd_addr = 0;
        rd_en   = 1;
        wr_en   = 0;
        @(negedge clk);
        rd_en   = 0;
        rd_addr = 1;
        @(posedge clk); #1;
        if (rd_data != 8'hAA)
            $fatal(1, "FAIL: expected=aa got=%0h", rd_data);

        rd_en = 0;
        wr_en = 0;

        $display("TEST 5: PASSED");
    endtask

    ////////////////////////
    // BACK TO BACK WRITE READ
    ////////////////////////

    task automatic b2b_wr_rd_test();
        $display("TEST 6: Consecutive Write/Reads");
        
        wr_en   = 0;
        wr_data = '0;
        wr_addr = '0;
        rd_en   = 0;
        rd_addr = 0;

        @(negedge clk);
        for (int j = 0; j < DEPTH; j++) begin
            rd_en   = 0;
            wr_en   = 1;
            wr_data = j;
            wr_addr = j;
            @(negedge clk);
            wr_en   = 0;
            rd_en   = 1;
            rd_addr = j;
            @(negedge clk);
            if (rd_data != j)
                $fatal(1, "FAIL: unexpected output");
        end
        wr_en = 0;
        rd_en = 0;

        $display("TEST 6: PASSED");
    endtask

    ////////////////////////
    // INDEPENDENT WRITE/READ
    ////////////////////////

    task automatic idp_wr_rd_test();
        $display("TEST 7: Independent Write/Read");
        
        wr_en   = 0;
        wr_addr = '0;
        wr_data = '0;
        rd_en   = 0;
        rd_addr = 0;

        @(negedge clk);
        wr_en = 1;
        for (int i = 0; i < 8; i++) begin
            wr_data = i*3;
            wr_addr = i;
            @(negedge clk);
        end
        wr_en = 0;

        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        for (int i = 0; i < 8; i++) begin
            wr_data = (i + 8)*3;
            wr_addr = i + 8;
            rd_addr = i;
            @(negedge clk);
            if (rd_data != (i*3))
                $fatal(1, "FAIL: expected=%0h, got=%0h",
                        (i*3),
                        rd_data);
            if (dut.mem[wr_addr] != ((i + 8) * 3))
                $fatal(1, "FAIL: mem write failed");
        end
        wr_en = 0;
        rd_en = 0;
        
        $display("TEST 7: PASSED");
    endtask

    ////////////////////////
    // COLLISION
    ////////////////////////

    task automatic collision_test();
        $display("TEST 8: Collision");

        wr_en   = 0;
        rd_en   = 0;
        wr_addr = '0;
        rd_addr = '0;
        wr_data = '0;

        @(negedge clk);
        wr_en   = 1;
        wr_data = 8'hEE;

        @(negedge clk);
        rd_en = 1;
        wr_data = 8'h55;
        @(posedge clk); #1;
        if (rd_data != 8'h55)
            $fatal(1, "FAIL: expected=55, got=%0h", rd_data);
        if (dut.mem[wr_addr] != 8'h55)
            $fatal(1, "FAIL: mem write fail");
        wr_en = 0;
        @(posedge clk); #1;
        if (rd_data != 8'h55)
            $fatal(1, "FAIL: expected=55, got=%0h", rd_data);
        
        rd_en = 0;
        
        $display("TEST 8: PASSED");
    endtask

    initial begin
        #1;
        reset_test();       #1;
        wr_re_test();       #1;
        multi_addr_test();  #1;
        repeated_wr_test(); #1;
        enable_low_test();  #1;
        b2b_wr_rd_test();   #1;
        idp_wr_rd_test();   #1;
        collision_test();   #1;


        #10;
        $display("==========================");
        $display("   ALL TEST ARE PASSED    ");
        $display("==========================");

        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, dpram_tb);
    end

endmodule
