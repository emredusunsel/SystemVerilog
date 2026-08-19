`timescale 1ps/1ps

module exhaustive_tb;

    localparam int WIDTH = 8;
    localparam int POLYNOMIAL = 9'b1000_1110;

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

    /////////////////////////////////
    // FULL SEQUENCE EXHAUSTIVE TEST
    /////////////////////////////////

    task automatic full_seq_test();
        logic [WIDTH-1:0] tracker [255];
        $display("==================");
        $display("FULL SEQUENCE TEST");
        $display("==================");
    
        @(negedge clk);
        seed = 8'b0000_0001;
        seed_valid = 1;
        enable = 1;
        @(negedge clk);
        seed_valid = 0;

        for (int i = 0; i < 255; i++) begin
            tracker[i] = lfsr_data;
            @(negedge clk);
            if (dut.state == DONE) begin
                enable = 0;
                $display("DONE reached");
            end
        end

        for (int j = 0; j < 255; j++) begin
            for (int k = 0; k < 255; k ++) begin
                if ((j != k) && (tracker[j] == tracker[k]))
                    $fatal(1, "%b = %b", tracker[j], tracker[k]);
            end
        end

        $display("255 unique stages seen");


        enable = 0;
        seed = '0;
        $display("==================");
        $display("    TEST PASSED   ");
        $display("==================");
    endtask

    //////////////////////////
    // MULTI NON-ZERO SEED DONE CHECK
    //////////////////////////

    task automatic multi_seed_done_test();
        $display("*************");

        @(negedge clk);
        enable = 1;
        seed_valid = 1;
        seed = 1;
        @(negedge clk);
        for (int i = 1; i < 256; i++) begin
            for (int j = 0; j < 255; j++) begin
                if (sequence_done) begin
                    seed = i;
                    seed_valid = 1;
                    @(negedge clk);
                end else begin
                    seed_valid = 0;
                    @(negedge clk);
                end
            end
        end

        $display("Every non-zero seed gets to DONE");
        $display("*************");
    endtask

    initial begin
        #10;
        rstn = 1;
        full_seq_test();    #1;
        multi_seed_done_test();
        #10;
        $finish;
    end

    initial begin
        $dumpfile("wave2.vcd");
        $dumpvars(0, exhaustive_tb);
    end

endmodule
