`timescale 1ps/1ps

module lfsr_tb;

    localparam int WIDTH = 4;
    localparam int POLYNOMIAL = 4'b1100;

    localparam int INIT = {1'b1, (WIDTH-1)'(0)};

    string current_state;

    typedef enum logic [1:0] {
        IDLE,
        RUN,
        DONE,
        LOCKED
    } state_t;

    logic clk, rstn, enable, seed_valid, clear, valid, locked, sequence_done;
    logic [WIDTH-1:0] seed, lfsr_data;

    lfsr_temp # (
        .WIDTH(WIDTH),
        .POLYNOMIAL(POLYNOMIAL)
    ) dut (
        .clk(clk),
        .rstn(rstn),
        .enable(enable),
        .seed_valid(seed_valid),
        .seed(seed),
        .clear(clear),
        .lfsr_data(lfsr_data),
        .valid(valid),
        .locked(locked),
        .sequence_done(sequence_done)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rstn = 0;
        enable = 0;
        seed_valid = 0;
        seed = '0;
        clear = 0;
    end

    always #1 current_state = dut.state.name();


    // LFSR STEP CHECK
    task automatic check_steps();
        logic [WIDTH-1:0] lfsr_step;
        
        @(negedge clk);
        lfsr_step = {lfsr_data[WIDTH-2:0], ^(lfsr_data & POLYNOMIAL)};
        
        @(posedge clk); #1;
        if ((dut.state != DONE) && (lfsr_data != lfsr_step))
            $fatal(1, "FAIL: step %b %b", lfsr_step, lfsr_data);
    endtask

    // CHECK THE VALUES
    task automatic check(
        input logic [1:0] exp_state,
        input logic [WIDTH-1:0] exp_lfsr_data,
        input logic exp_valid,
        input logic exp_locked,
        input logic exp_seq_done
    );
        @(posedge clk); #1;
        if (dut.state != exp_state)
            $fatal(1, "FAIL: state=%0s exp=%0b",
                current_state,
                exp_state);
        if (lfsr_data != exp_lfsr_data)
            $fatal(1, "FAIL: lfsr_data=%b exp=%b",
                lfsr_data,
                exp_lfsr_data);
        if (valid != exp_valid)
            $fatal(1, "FAIL: valid=%0d exp=%0b",
                valid,
                exp_valid);
        if (locked != exp_locked)
            $fatal(1, "FAIL: locked=%0b exp=%0b",
                locked,
                exp_locked);
        if (sequence_done != exp_seq_done)
            $fatal(1, "FAIL: sequence_done=%0b exp=%0b",
                sequence_done,
                exp_seq_done);
    endtask

    //////////////////////
    // RESET
    //////////////////////

    task automatic reset_test();
        $display("TEST 1: Reset");

        rstn = 0;
        check(IDLE, INIT, 1, 0, 0);

        @(negedge clk);
        rstn = 1;
        check(IDLE, INIT, 1, 0, 0);

        $display("TEST 1: PASSED");
    endtask

    //////////////////////
    // IDLE HOLD
    //////////////////////

    task automatic idle_hold_test();
        $display("TEST 2: IDLE Hold");

        seed_valid = 0;
        enable = 0;
        clear = 0;
        repeat (10) @(posedge clk);
        check(IDLE, INIT, 1, 0, 0);

        $display("TEST 2: PASSED");
    endtask

    //////////////////////
    // START RUN
    //////////////////////

    task automatic start_run_test();
        $display("TEST 3: Start RUN");

        @(negedge clk);
        enable = 1;
        check(RUN, 4'b0001, 1, 0, 0);
        repeat (5) check_steps();

        $display("TEST 3: PASSED");
    endtask

    //////////////////////
    // STOP RUN
    //////////////////////

    task automatic stop_run_test();
        logic [WIDTH-1:0] last_data;
        $display("TEST 4: Stop RUN");

        @(negedge clk);
        enable = 0;
        last_data = lfsr_data;
        check(IDLE, last_data, 1, 0, 0);

        repeat (10) check(IDLE, last_data, 1, 0, 0);

        $display("TEST 4: PASSED");        
    endtask

    //////////////////////
    // RESUME RUN
    //////////////////////

    task automatic resume_run_test();
        $display("TEST 5: Resume RUN");

        enable = 1;
        check_steps();

        $display("TEST 5: PASSED");
    endtask

    //////////////////////
    // VALID SEED LOAD FROM IDLE
    //////////////////////

    task automatic valid_seed_load_test();
        $display("TEST 6: Valid Seed Load");

        @(negedge clk);
        seed_valid = 1;
        seed = {$urandom, 1'b1};
        enable = 0;
        check(IDLE, seed, 1, 0, 0);
        @(negedge clk);
        seed_valid = 0;
        check(IDLE, seed, 1, 0, 0);

        $display("TEST 6: PASSED");
    endtask

    //////////////////////
    // VALID SEED LOAD + ENABLE
    //////////////////////

    task automatic valid_seed_en_test();
        $display("TEST 7: Valid Seed Load + Enable Simultaneously");

        @(negedge clk);
        seed_valid = 1;
        seed = 4'hA;        // DEFAULT WIDTH IS 8
        enable = 1;
        check(IDLE, 4'hA, 1, 0, 0);
        seed_valid = 0;
        check(RUN, 4'b0101, 1, 0, 0);      // dependant on WIDTH AND POLYNOMIAL

        $display("TEST 7: PASSED");
    endtask

    //////////////////////
    // ZERO SEED FROM IDLE
    //////////////////////

    task automatic zero_idle_test();
        $display("TEST 8: Zero Seed from IDLE");

        enable = 0;
        check(IDLE, 4'b0101, 1, 0, 0);
        @(negedge clk);
        seed_valid = 1;
        seed = '0;
        check(LOCKED, '0, 0, 1, 0);
        enable = 1;
        repeat (10) @(posedge clk);
        check(LOCKED, '0, 0, 1, 0);

        $display("TEST 8: PASSED");
    endtask

    //////////////////////
    // LOCKED RECOVER
    //////////////////////

    task automatic locked_recover_test();
        $display("TEST 9: Recover from LOCKED");

        @(negedge clk);
        seed_valid = 1;
        seed = 4'hB;        // WIDTH dependant
        check(IDLE, seed, 1, 0, 0);
        seed_valid = 0;
        enable = 1;
        repeat (5) check_steps();

        $display("TEST 9: PASSED");
    endtask

    //////////////////////
    // CLEAR FROM EVERY STATE
    //////////////////////

    task automatic clear_all_test();
        $display("TEST 10: Clear from Every State");

        @(negedge clk);
        clear = 1;
        // current_state RUN
        check(IDLE, INIT, 1, 0, 0);
        clear = 0;
        enable = 0;
        seed_valid = 1;
        seed = 4'hC;            // WIDTH DEPENDANT
        check(IDLE, 4'hC, 1, 0, 0);
        clear = 1;
        // current state IDLE
        check(IDLE, INIT, 1, 0, 0);
        clear = 0;
        seed_valid = 1;
        seed = 4'b1011;
        @(posedge clk); #1;
        seed_valid = 0;
        enable = 1;
        wait(dut.next_state == DONE);
        clear = 1;
        // current state DONE
        check(IDLE, INIT, 1, 0, 0);
        clear = 0;
        seed = '0;
        seed_valid = 1;
        // current state LOCKED
        check(LOCKED, '0, 0, 1, 0);
        seed_valid = 0;
        repeat (3) @(negedge clk);
        clear = 1;
        check(IDLE, INIT, 1, 0, 0);

        clear = 0;
        enable = 0;
        $display("TEST 10: PASSED");
    endtask

    //////////////////////
    // CLEAR PRIORITY
    //////////////////////

    task automatic clear_prio_test();
        $display("TEST 11: Clear Priority");
        
        @(negedge clk);
        enable = 1;
        @(negedge clk);
        clear = 1;
        check(IDLE, INIT, 1, 0, 0);
        enable = 0;
        clear = 0;
        @(negedge clk);
        seed = 4'h5;
        seed_valid = 1;
        @(negedge clk);
        clear = 1;
        check(IDLE, INIT, 1, 0, 0);
        @(negedge clk);
        clear = 0;
        enable = 1;
        @(negedge clk);
        clear = 1;
        check(IDLE, INIT, 1, 0, 0);


        clear = 0;
        seed_valid = 0;
        enable = 0;
        seed = '0;
        $display("TEST 11: PASSED");
    endtask

    //////////////////////
    // SEED PRIORITY
    //////////////////////

    task automatic seed_prio_test();
        $display("TEST 12: Seed Priority");

        @(negedge clk);
        seed = 4'h7;
        seed_valid = 1;
        enable = 1;
        check(IDLE, 4'h7, 1, 0, 0);

        seed_valid = 0;
        repeat (3) @(negedge clk);
        seed_valid = 1;
        check(IDLE, 4'h7, 1, 0, 0);

        seed_valid = 0;
        wait(dut.state == DONE);
        seed_valid = 1;
        check(IDLE, 4'h7, 1, 0, 0);

        seed = '0;
        check(LOCKED, '0, 0, 1, 0);
        seed = 4'h7;
        seed_valid = 0;
        check(LOCKED, '0, 0, 1, 0);
        seed_valid = 1;
        check(IDLE, 4'h7, 1, 0, 0);

        seed = '0;
        seed_valid = 0;
        enable = 0;
        $display("TEST 12: PASSED");
    endtask

    //////////////////////
    // RUN -> DONE
    //////////////////////

    task automatic run_till_done_test();
        $display("TEST 13: RUN -> DONE");
    
        @(negedge clk);
        seed = 4'b0001;
        seed_valid = 1;
        enable = 1;
        @(negedge clk);
        seed_valid = 0;
        wait(dut.next_state == DONE);
        check(DONE, seed, 1, 0, 1);
        check(RUN, 4'b0010, 1, 0, 0);

        enable = 0;
        seed_valid = 0;
        seed = '0;
        $display("TEST 13: PASSED");
    endtask

    //////////////////////
    // NO FALSE DONE
    //////////////////////

    task automatic no_false_done_test();
        $display("TEST 14: No False DONE");

        @(negedge clk);
        seed = 4'h9;
        seed_valid = 1;
        check(IDLE, seed, 1, 0, 0);
        seed_valid = 0;
        check(IDLE, seed, 1, 0, 0);
        enable = 1;
        check(RUN, 4'b0011, 1, 0, 0);

        enable = 0;
        seed = '0;
        $display("TEST 14: PASSED");
    endtask

    //////////////////////
    // PAUSE DURING A SEQUENCE
    //////////////////////

    task automatic pause_during_seq_test();
        logic [WIDTH-1:0] lfsr_keep;
        logic [WIDTH-1:0] next_lfsr_keep;
        $display("TEST 15: Enable Pausing During a Sequence");

        @(negedge clk);
        seed = 4'b1101;
        seed_valid = 1;
        enable = 1;
        @(negedge clk);
        seed_valid = 0;

        repeat (4) @(negedge clk);
        lfsr_keep = lfsr_data;
        next_lfsr_keep = {lfsr_keep[2:0], ^(lfsr_keep & POLYNOMIAL)};
        enable = 0;
        repeat (10) check(IDLE, lfsr_keep, 1, 0, 0);

        enable = 1;
        check(RUN, next_lfsr_keep, 1, 0, 0);

        @(negedge clk);
        enable = 0;
        seed = '0;
        $display("TEST 15: PASSED");
    endtask

    //////////////////////
    // SEED LOAD FROM RUN INIT SEED UPDATE
    //////////////////////

    task automatic seed_init_update_test();
        $display("TEST 16: Seed Loaded from RUN must update seed_init");

        @(negedge clk);
        seed = 4'hA;
        seed_valid = 1;
        enable = 1;
        @(negedge clk);
        seed_valid = 0;
        repeat (5) @(negedge clk);
        seed = 4'h5;
        seed_valid = 1;
        @(negedge clk);
        seed_valid = 0;
        wait(dut.state == DONE); #1;
        if (lfsr_data != 4'h5)
            $fatal();
        
        seed = '0;
        enable = 0;
        $display("TEST 16: PASSED");
    endtask

    //////////////////////
    // ZERO SEED FROM RUN PUT LFSR TO ZERO
    //////////////////////

    task automatic zero_from_run_lfsr_test();
        $display("TEST 17: Zero Loaded from RUN -> LFSR zero");

        @(negedge clk);
        enable = 1;
        @(negedge clk);
        seed = '0;
        seed_valid = 1;
        check(LOCKED, '0, 0, 1, 0);
        seed_valid = 0;
        repeat (20) @(negedge clk);
        check(LOCKED, '0, 0, 1, 0);
        seed_valid = 1;
        seed = 4'hA;
        check(IDLE, 4'hA, 1, 0, 0);

        enable = 0;
        seed = '0;
        seed_valid = 0;
        $display("TEST 17: PASSED");
    endtask

    //////////////////////
    // SEED LOAD FROM DONE
    //////////////////////

    task automatic seed_load_from_done();
        $display("TEST 18: Seed Load From DONE");

        @(negedge clk);
        seed = 4'h4;
        seed_valid = 1;
        enable = 1;
        @(negedge clk);
        seed_valid = 0;
        seed = 4'h8;
        wait(sequence_done);
        seed_valid = 1;
        check(IDLE, 4'h8, 1, 0, 0);

        $display("TEST 18: PASSED");
    endtask

    initial begin
        #10;
        reset_test();               #1;
        idle_hold_test();           #1;
        start_run_test();           #1;
        stop_run_test();            #1;
        resume_run_test();          #1;
        valid_seed_load_test();     #1;
        valid_seed_en_test();       #1;
        zero_idle_test();           #1;
        locked_recover_test();      #1;
        clear_all_test();           #1;
        clear_prio_test();          #1;
        seed_prio_test();           #1;
        run_till_done_test();       #1;
        no_false_done_test();       #1;
        pause_during_seq_test();    #1;
        seed_init_update_test();    #1;
        zero_from_run_lfsr_test();  #1;
        seed_load_from_done();      #1;

        $display("=========================");
        $display("  ALL TESTS ARE PASSED");
        $display("=========================");

        #10;
        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, lfsr_tb);
    end

endmodule
