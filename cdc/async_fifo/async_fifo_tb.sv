`timescale 1ns/1ps

module async_fifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;

    logic wr_clk, wr_rstn, wr_en;
    logic [WIDTH-1:0] wr_data;
    logic full;

    logic rd_clk, rd_rstn, rd_en;
    logic [WIDTH-1:0] rd_data;
    logic  empty;

    async_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .wr_clk  (wr_clk),
        .wr_rstn (wr_rstn),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .full    (full),

        .rd_clk  (rd_clk),
        .rd_rstn (rd_rstn),
        .rd_en   (rd_en),
        .rd_data (rd_data),
        .empty   (empty)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, async_fifo_tb);
    end

    initial begin
        wr_rstn = 0;
        rd_rstn = 0;

        wr_en = 0;
        rd_en = 0;
        wr_data = '0;
    end

    initial begin
        wr_clk = 0;
        forever
            #7 wr_clk = ~wr_clk;
    end

    initial begin
        rd_clk = 0;
        forever
            #7 rd_clk = ~rd_clk;
    end

    ///////////////////////////////
    // RESET TEST
    ///////////////////////////////

    task automatic test_reset();
        $display("TEST 1: RESET");
        wr_rstn = 0;
        rd_rstn = 0;

        #1;
        if ((full !== 0) || (empty !== 1) || (rd_data !== '0)) begin
            $fatal(1, "RESET FAIL");
        end

        repeat (5)
            @(posedge wr_clk);
        wr_rstn = 1;
        repeat (5)
            @(posedge rd_clk);
        rd_rstn = 1;
        #1;

        if (!empty) begin
            $fatal(1,"FAIL: empty not asserted after reset");
        end else 
            $display("TEST 1: PASS");
    endtask

    ///////////////////////////////
    // SINGLE WRITE/READ TEST
    ///////////////////////////////

    task automatic test_single_wr(input logic [WIDTH-1:0] data);
        $display("TEST 2: Single Write/Read");
        @(negedge wr_clk);
        wr_en   = 1;
        wr_data = data;
        @(negedge wr_clk);
        wr_en   = 0;

        wait (!empty);
        @(negedge rd_clk);
        rd_en   = 1;
        @(negedge rd_clk);

        if (data !== rd_data)
            $fatal(1, "FAIL: expected=%d got=%d", data, rd_data);

        rd_en   = 0;

        #1;
        $display("TEST 2: PASS");
    endtask

    ///////////////////////////////
    // MULTIPLE SEQUENTIAL WRITES
    ///////////////////////////////

    task automatic test_seq_write(int i);
        logic [4:0] wr_ptr_mem, rd_ptr_mem;
        logic [WIDTH-1:0] data_mem [DEPTH];

        $display("TEST 3: Multiple Sequential Write");
        
        wr_ptr_mem = dut.wr_ptr;
        rd_ptr_mem = dut.rd_ptr;

        // WRITE PART
        for(int j = 0; j < i; j++) begin
            @(negedge wr_clk);
            wr_en       = 1;
            wr_data     = $urandom;
            data_mem[j] = wr_data;
            @(negedge wr_clk);
            wr_en       = 0;

            wr_ptr_mem = wr_ptr_mem + 1;
        end

        // READ PART
        for (int k = 0; k < i; k++) begin
            @(negedge rd_clk);
            rd_en   = 1;
            @(negedge rd_clk);

            if (data_mem[k] !== rd_data)
                $fatal(1, "FAIL: got data_mem=%d expected rd_data=%d",
                data_mem[k],
                rd_data);

            rd_en   = 0;

            rd_ptr_mem = rd_ptr_mem + 1;
        end
        #1;


        // CHECKING RESULTS
        if (((wr_ptr_mem) === dut.wr_ptr) &&
            ((rd_ptr_mem) === dut.rd_ptr))
            $display("TEST 3: PASS");
        else
            $fatal(1,"FAIL: ptr_mems=(wr=%d rd=%d) doesn't match with ptrs=(wr=%d rd=%d)",
            wr_ptr_mem,
            rd_ptr_mem,
            dut.wr_ptr,
            dut.rd_ptr);

        if (!empty) begin
            $fatal(1, "expected empty=1");
        end

    endtask

    ///////////////////////////////
    // FILL FIFO
    ///////////////////////////////

    task automatic test_fill(int i);
        logic [WIDTH-1:0] temp_mem [DEPTH];
        logic [4:0] ptr_catch = '0;

        $display("TEST 4: Fill FIFO");

        ptr_catch = dut.wr_ptr;

        // FILL FIFO
        for (int j = 0; j < i; j++) begin
            @(negedge wr_clk);
            wr_en                       = 1;
            wr_data                     = j;
            @(negedge wr_clk);

            // FILL TEMP MEM FOR LATER CHECK
            if (j < DEPTH) begin
                temp_mem[ptr_catch[3:0]] = wr_data;
                ptr_catch = ptr_catch + 1;
            end
            
            wr_en = 0;
        end

        // CHECK CONTENTS OF MEMORY
        for (int k = 0; k < DEPTH; k++) begin
            if (dut.mem[k] !== temp_mem[k])
                $fatal(1, "FAIL: data mismatch mem[%0d]=%0d while temp[%0d]=%0d",
                    k,
                    dut.mem[k],
                    k,
                    temp_mem[k]);

            // CHECK UNWRITTEN DATA
            for (int inner_k = 0; inner_k < DEPTH; inner_k++) begin
               if (dut.mem[k] === (inner_k + 16))
                    $fatal(1, "FAIL: should not be written mem[%0d]=%0d and %0d",
                        k,
                        dut.mem[k],
                        (inner_k+16));
            end

        end

        $display("TEST 4: PASS");

    endtask

    ///////////////////////////////
    // DRAIN FIFO
    ///////////////////////////////

    task automatic test_drain(int i);
        logic [4:0] ptr_catch = '0;
        $display("TEST 5: Drain FIFO");

        ptr_catch = dut.rd_ptr;

        for (int j = 0; j < i; j++) begin
            @(negedge rd_clk);
            rd_en   = 1;
            @(negedge rd_clk);

            if (j < DEPTH)
                ptr_catch = ptr_catch + 1;

            rd_en   = 0;
        end

        if (!empty)
            $fatal(1,"empty not asserted");

        if (ptr_catch !== dut.rd_ptr)
            $fatal(1,"FAIL: pointer missmatch ptr=%0d catch=%0d",
                dut.rd_ptr,
                ptr_catch);

        $display("TEST 5: PASS");

    endtask

    ///////////////////////////////
    // SIMULTANEOUS READ/WRITE
    ///////////////////////////////

    task automatic test_smt_rdwr();

        int fd;
        fd = $fopen("output.txt", "w");

        if (fd == 0) begin
            $display("Error: couldnt open file");
            $finish;
        end
        $display("TEST 6: Simultaneous Read/Write");

        // FILL FIFO A LITTLE
        @(negedge wr_clk);
        wr_en = 1;
        wr_data = $urandom;
        repeat (5) begin
            @(negedge wr_clk);
            wr_data = $urandom;
        end

        @(negedge rd_clk);
        rd_en = 1;

        for (int i = 0; i < 40; i ++) begin
            @(negedge wr_clk);
            wr_data = i;
            // mem check
            for (int j = 0; j < DEPTH; j++) begin
                if (j == dut.wr_ptr[3:0])
                    $fdisplay(fd, "mem[%0d] = %d *wr*", j, dut.mem[j]);
                else if (j == dut.rd_ptr[3:0])
                    $fdisplay(fd, "mem[%0d] = %d *rd*", j, dut.mem[j]);
                else if (j == 0) begin
                    $fdisplay(fd, "========================");
                    $fdisplay(fd, "mem[%0d] = %d", j, dut.mem[j]);
                end else
                    $fdisplay(fd, "mem[%0d] = %d", j, dut.mem[j]);
            end
            $fdisplay(fd, "data = %0d full = %0d", rd_data, full);
            $fdisplay(fd, "========================");
        end


        @(negedge wr_clk);
        wr_en = 0;
        @(negedge rd_clk);
        rd_en = 0;

        $fclose(fd);

        $display("TEST 6: MANUEL CHECK NEEDED");

    endtask


    // write task
    task automatic write_fifo(input logic [WIDTH-1:0] data);
        @(negedge wr_clk);
        wr_en = 1;
        wr_data = data;
        @(negedge wr_clk);
        $display("WRITE: data=%0d empty=%0b full=%0b", wr_data, empty, full);
        wr_en = 0;
    endtask

    // read task
    task automatic read_fifo();
        @(negedge rd_clk);
        rd_en = 1;
        @(negedge rd_clk);
        $display("READ: data=%0d empty=%0b full=%b", rd_data, empty, full);
        rd_en = 0;
    endtask

    initial begin
        // test different clocks wr=rd wr<rd wr>rd
        // wr>rd : PASSED
        // wr=rd : PASSED
        // wr<rd : PASSED
    
        // default #5 wr_clk | #7 rd_clk

        test_reset();
        wait (wr_rstn && rd_rstn);

        test_single_wr($urandom);
        #1;
        test_seq_write(5);
        #1;
        test_fill(20);
        #1;
        test_drain(20);
        #1;
        test_smt_rdwr();
        #1;

        $display("======================");
        $display("   ALL TESTS PASSED");
        $display("======================");

        $finish;
    end


endmodule
