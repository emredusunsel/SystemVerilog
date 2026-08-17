`timescale 1ps/1ps

module lifo_tb;

    localparam int WIDTH = 8;
    localparam int DEPTH = 16;
    localparam int PTR_WIDTH = $clog2(DEPTH) + 1;

    logic clk, rstn, push;
    logic [WIDTH-1:0] push_data;
    logic pop;
    logic [WIDTH-1:0] pop_data;
    logic empty, full;
    logic [$clog2(DEPTH):0] count;

    lifo # (
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk        (clk),
        .rstn       (rstn),
        .push       (push),
        .push_data  (push_data),
        .pop        (pop),
        .pop_data   (pop_data),
        .empty      (empty),
        .full       (full),
        .count      (count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn        = 0;
        push        = 0;
        push_data   = '0;
        pop         = 0;
    end


    // CHECK THE EXPECTED VALUES
    task automatic check(
        input logic [WIDTH-1:0] ch_pop_data,
        input logic ch_empty,
        input logic ch_full,
        input logic [$clog2(DEPTH):0] ch_count
    );
        @(posedge clk); 
        #1;

        if (ch_pop_data !== pop_data)
            $fatal(1, "FAIL: pop_data expected=%0h, got=%0h",
                    ch_pop_data,
                    pop_data);
        if (ch_empty !== empty)
            $fatal(1, "FAIL: empty expected=%0d, got=%0d",
                    ch_empty,
                    empty);
        if (ch_full !== full)
            $fatal(1, "FAIL: full expected=%0d, got=%0d",
                    ch_full,
                    full);
        if (ch_count !== count)
            $fatal(1, "FAIL: count expected=%0d, got=%0d",
                    ch_count,
                    count);
    endtask

    //////////////////////
    // RESET
    /////////////////////

    task automatic reset_test();
        $display("TEST 1: Reset");

        rstn = 0;
        check('0, 1, 0, 0);
        @(negedge clk); rstn = 1;
        check('0, 1, 0, 0);

        $display("TEST 1: PASS");        
    endtask

    //////////////////////
    // SINGLE PUSH
    /////////////////////

    task automatic single_push_test();
        $display("TEST 2: Single Push");

        @(negedge clk); 
        push_data = 8'hAA;
        push = 1;
        check('0, 0, 0, 1);
        
        push_data = '0;
        push = 0;
        $display("TEST 2: PASSED");
    endtask

    //////////////////////
    // SINGLE POP
    /////////////////////

    task automatic single_pop_test();
        $display("TEST 3: Single Pop");
        
        @(negedge clk);
        pop = 1;
        check(8'hAA, 1, 0, 0);

        pop = 0;
        $display("TEST 3: PASSED");
    endtask

    //////////////////////
    // LIFO OREDERING
    /////////////////////

    task automatic lifo_order_test();
        $display("TEST 4: LIFO OREDERING");
        
        @(negedge clk);
        push = 1;
        for (int i = 0; i < 4; i++) begin
            push_data = i;
            check(8'hAA, 0, 0, (i + 1));
            @(negedge clk);
        end
        push = 0;
        push_data = '0;

        @(negedge clk);
        pop = 1;
        for (int i = 0; i < 4; i++) begin
            if (i !== 3)
                check((3-i), 0, 0, (3 - i));
            else
                check((3-i), 1, 0, (3 - i));
            @(negedge clk);
        end

        pop = 0;
        $display("TEST 4: PASSED");
    endtask

    //////////////////////
    // FILL LIFO
    /////////////////////

    task automatic fill_test();
        $display("TEST 5: Fill the Stack");

        @(negedge clk);
        push = 1;
        for (int i = 0; i < DEPTH; i++) begin
            push_data = {4'(i), 4'(i)};
            if (i === (DEPTH - 1))
                check('0, 0, 1, (i + 1));
            else
                check('0, 0, 0, (i + 1));
        end
        push = 0;
        push_data = '0;

        $display("TEST 5: PASSED");
    endtask

    //////////////////////
    // OVERFLOW
    /////////////////////

    task automatic overflow_test();
        $display("TEST 6: Overflow");
        
        check('0, 0, 1, DEPTH);

        @(negedge clk);
        push = 1;
        push_data = 8'hEE;
        check('0, 0, 1, DEPTH);
        for (int i = 0; i < DEPTH; i++) begin
            if (dut.mem[i] !== {4'(i), 4'(i)})
                $fatal(1, "FAIL: mem contents changed");
        end
        push = 0;
        push_data = '0;

        $display("TEST 6: PASSED");
    endtask

    //////////////////////
    // DRAIN LIFO
    /////////////////////

    task automatic drain_test();
        $display("TEST 7: Drain the Stack");

        check('0, 0, 1, DEPTH);

        @(negedge clk);
        pop = 1;
        for (int i = 0; i < DEPTH; i++) begin
            if (i === (DEPTH-1))
                check({4'(DEPTH-1-i), 4'(DEPTH-1-i)}, 1, 0, (DEPTH-1-i));
            else
                check({4'(DEPTH-1-i), 4'(DEPTH-1-i)}, 0, 0, (DEPTH-1-i));
        end
        pop = 0;

        $display("TEST 7: PASSED");        
    endtask

    //////////////////////
    // UNDERFLOW
    /////////////////////

    task automatic underflow_test();
        $display("TEST 8: Underflow");

        check('0, 1, 0, 0);

        @(negedge clk);
        pop = 1;
        check('0, 1, 0, 0);
        pop = 0;

        $display("TEST 8: PASSED");
    endtask

    //////////////////////
    // SIMULTANEOUS PUSH/POP
    /////////////////////

    task automatic simultaneous_pp_test();
        $display("TEST 9: Simultaneous Push/Pop");
        
        @(negedge clk);
        push = 1;
        push_data = 8'h0A;
        @(negedge clk);
        push_data = 8'h0B;
        @(negedge clk);
        push_data = 8'h0C;
        @(negedge clk);
        push_data = 8'h0D;
        check('0, 0, 0, 4);
        
        @(negedge clk);
        pop = 1;

        for (int i = 0; i < 20; i++) begin
            push_data = i;
            if (i === 0)
                check(8'h0D, 0, 0, 4);
            else
                check((i - 1), 0, 0, 4);
        end
        push_data = '0;
        push = 0;
        pop = 0;

        $display("TEST 9: PASSED");
    endtask

    //////////////////////
    // SIMULTANEOUS OP WHILE EMPTY
    /////////////////////

    task automatic sim_op_empty_test();
        $display("TEST 10: Simultaneous Ops while Empty");

        @(negedge clk);
        pop = 1;
        wait (empty);
        check(8'h0A, 1, 0, 0);

        @(negedge clk);
        push = 1;
        push_data = 8'h55;
        check(8'hA, 0, 0, 1);
        if (dut.mem[0] !== 8'h55)
            $fatal(1, "FAIL: push op not accepted %0h");
        pop = 0;
        push = 0;
        push_data = '0;

        $display("TEST 10: PASSED");
    endtask

    //////////////////////
    // SIMULTANEOUS OP WHILE FULL
    /////////////////////

    task automatic sim_op_full_test();
        $display("TEST 11: Simultaneous Ops While Full");

        @(negedge clk);
        pop = 1;
        wait (empty);
        pop = 0;

        @(negedge clk);
        push = 1;
        for (int i = 0; i < DEPTH; i++) begin
            push_data = i*4;
            @(negedge clk);
        end

        check(8'h55, 0, 1, (DEPTH));
        @(negedge clk);
        pop = 1;

        for (int i = 0; i < 20; i++) begin
            push_data = i;
            if (i === 0)
                check(((DEPTH-1)*4), 0, 1, DEPTH);
            else
                check((i - 1), 0, 1, DEPTH);
        end
        push = 0;
        pop = 0;
        push_data = '0;

        $display("TEST 11: PASSED");
    endtask

    initial begin
        #10;
        reset_test(); #1;
        single_push_test(); #1;
        single_pop_test(); #1;
        lifo_order_test(); #1;
        fill_test(); #1;
        overflow_test(); #1;
        drain_test(); #1;
        underflow_test(); #1;
        simultaneous_pp_test(); #1;
        sim_op_empty_test(); #1;
        sim_op_full_test(); #1;
        
        $display("=========================");
        $display("   ALL TESTS ARE PASSED  ");
        $display("=========================");
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, lifo_tb);
    end

endmodule
