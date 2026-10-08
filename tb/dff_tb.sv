`timescale 1ps/1ps

module dff_tb;

    logic clk_i, rstn_i, en_i, d_i, q_o;

    dff dut (
        .*
    );

    time last_posedge;
    bit have_posedge = 0;
    logic q_before_falling;

    // Track reset pulses that occur entirely between assertion clock samples.
    // This preserves reset cancellation on Verilator for the short-pulse test.
    int unsigned reset_generation = 0;
    always @(negedge rstn_i)
        reset_generation++;

    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

//========================//
//        PROPERTIES      //
//========================//

    property p_reset_held_active;
        @(posedge clk_i)
        !rstn_i |-> (q_o === 1'b0);
    endproperty

    property p_enabled_capture;
        @(posedge clk_i) disable iff (!rstn_i)
        en_i |=> ((reset_generation != $past(reset_generation)) ||
                  (q_o == $past(d_i)));
    endproperty

    property p_disabled_hold;
        @(posedge clk_i) disable iff (!rstn_i)
        !en_i |=> ((reset_generation != $past(reset_generation)) ||
                   (q_o == $past(q_o)));
    endproperty

    property p_known_output;
        @(posedge clk_i) disable iff (!rstn_i)
        !$isunknown(q_o);
    endproperty

//========================//
//        ASSERTIONS      //
//========================//

    a_reset_held_active: assert property (p_reset_held_active)
        else $fatal(1, "Reset held failed");
    a_enabled_capture:   assert property (p_enabled_capture)
        else $fatal(1, "Enable capture failed");
    a_disabled_hold:     assert property (p_disabled_hold)
        else $fatal(1, "Disabled hold failed");
    a_known_output:      assert property (p_known_output)
        else $fatal(1, "Output contains X or Z");

    always @(posedge clk_i) begin
        last_posedge = $time;
        have_posedge = 1;
    end

    always @(q_o) begin
        if (rstn_i === 1'b1) begin
            a_no_capture_between_edges: assert (have_posedge && ($time == last_posedge)) 
                else $fatal(1, "Output changed away from a rising edge");
        end
    end

    always @(negedge clk_i) begin
        q_before_falling = q_o;
        #1;

        a_falling_clock_edge: assert ((!rstn_i) || (q_o === q_before_falling)) 
            else $fatal(1, "Output changed on a falling edge");
    end

    always @(posedge rstn_i) begin
        #1;

        a_reset_release: assert (q_o === 1'b0)
            else $fatal(1, "Output changed on reset release");
    end

    always @(negedge rstn_i) begin
        #1;
        a_async_reset: assert (q_o === 1'b0) 
            else $fatal(1, "Asynchronous reset failed");
    end

    always @(q_o or rstn_i) begin
        #1;
        if (!rstn_i) begin
            a_reset_invariant: assert (q_o === 1'b0) 
                else $fatal(1, "Output nonzero while reset is active");
        end
    end

//========================//
//        COVERAGE        //
//========================//

    covergroup cg_dff @(posedge clk_i);
        option.per_instance = 1;

        cp_q: coverpoint q_o iff (rstn_i) {
            bins zero = {0};
            bins one = {1};
        }

        cp_d: coverpoint d_i iff (rstn_i) {
            bins zero = {0};
            bins one = {1};
        }

        cp_en: coverpoint en_i iff (rstn_i) {
            bins disabled = {0};
            bins enabled = {1};
        }

        normal_operation: cross cp_q, cp_d, cp_en;
    endgroup

    covergroup cg_reset @(negedge rstn_i);
        option.per_instance = 1;

        cp_q_before_reset: coverpoint q_o {
            bins already_zero = {0};
            bins clear_one = {1};
        }

        cp_clock_phase: coverpoint clk_i {
            bins low_phase = {0};
            bins high_phase = {1};
        }

        cp_en_at_reset: coverpoint en_i {
            bins disabled = {0};
            bins enabled = {1};
        }

        cp_d_at_reset: coverpoint d_i {
            bins zero = {0};
            bins one = {1};
        }

        reset_cases: cross cp_q_before_reset, cp_clock_phase;
        reset_controls: cross cp_en_at_reset, cp_d_at_reset;
    endgroup

    covergroup cg_reset_release @(posedge rstn_i);
        option.per_instance = 1;

        cp_release_controls: coverpoint {en_i, d_i} {
            bins disabled = {2'b00, 2'b01};
            bins enabled_zero = {2'b10};
            bins enabled_one = {2'b11};
        }
    endgroup

    covergroup cg_capture_sequence @(posedge clk_i or negedge rstn_i);
        option.per_instance = 1;

        cp_capture_pair: coverpoint {rstn_i, en_i, d_i} {
            bins zero_then_zero = (3'b110 => 3'b110);
            bins zero_then_one = (3'b110 => 3'b111);
            bins one_then_zero = (3'b111 => 3'b110);
            bins one_then_one = (3'b111 => 3'b111);
        }
    endgroup

    covergroup cg_disabled_hold @(posedge clk_i or negedge rstn_i);
        option.per_instance = 1;

        // Bit order: {reset inactive, enable, output, data}
        cp_hold_sequence: coverpoint {rstn_i, en_i, q_o, d_i} {
            bins hold_zero_data_rises = (4'b1000 => 4'b1001);
            bins hold_zero_data_falls = (4'b1001 => 4'b1000);

            bins hold_one_data_rises = (4'b1010 => 4'b1011);
            bins hold_one_data_falls = (4'b1011 => 4'b1010);
        }
    endgroup

    // Reset-Duration Coverage
    int unsigned reset_clock_count = 0;
    bit reset_seen = 0;

    logic reset_start_d, reset_start_en;
    bit reset_d_changed = 0;
    bit reset_en_changed = 0;

    // Start tracking a new reset pulse.
    always @(negedge rstn_i) begin
        reset_seen = 1;
        reset_clock_count = 0;

        reset_start_d = d_i;
        reset_start_en = en_i;

        reset_d_changed = 0;
        reset_en_changed = 0;
    end

    // Count risign clock edges during reset.
    always @(posedge clk_i) begin
        if (reset_seen && !rstn_i)
            reset_clock_count++;
    end

    // Rememeber whether each input changed during reset.
    always @(d_i or en_i) begin
        if (reset_seen && !rstn_i) begin
            if (d_i != reset_start_d)
                reset_d_changed = 1;
            if (en_i != reset_start_en)
                reset_en_changed = 1;
        end
    end

    covergroup cg_reset_duration @(posedge rstn_i);
        option.per_instance = 1;

        cp_short_reset: coverpoint (reset_clock_count == 0) iff (reset_seen) {
            bins occured = {1};
            ignore_bins other = {0};
        }

        cp_held_reset: coverpoint (
            (reset_clock_count >= 2) &&
            reset_d_changed &&
            reset_en_changed) iff (reset_seen) {
            bins occured = {1};
            ignore_bins other = {0};
        }
    endgroup
    
    cg_reset_duration duration_cov = new();
    // ----

    // Enable changes between rising edges
    // Data changes 1ps before or after falling edges
    time cov_last_fall;
    time cov_last_data_change;
    bit cov_have_fall = 0;
    bit cov_have_data_change = 0;

    covergroup cg_between_edges with function sample(
        int enable_direction,
        int data_position
    );
        option.per_instance = 1;

        cp_enable_change: coverpoint enable_direction {
            bins one_to_zero = {0};
            bins zero_to_one = {1};
            ignore_bins inactive = {-1};
        }

        cp_data_near_falling: coverpoint data_position {
            bins before_falling = {0};
            bins after_falling = {1};
            ignore_bins inactive = {-1};
        }
    endgroup
    
    cg_between_edges between_cov = new();

    // Enable changes between rising edges.
    // Continue driving stimilus away from rising clock edges.
    always @(en_i) begin
        if ((rstn_i === 1'b1) && have_posedge && ($time != last_posedge))
            between_cov.sample(int'(en_i), -1);
    end

    // Record data changes and detect changes 1ps after a falling edge
    always @(d_i) begin
        if (rstn_i === 1'b1) begin
            cov_last_data_change = $time;
            cov_have_data_change = 1;

            if (cov_have_fall && ($time == cov_last_fall + 1ps))
                between_cov.sample(-1, 1);
        end
    end

    // Detect data changes that occured 1ps before a falling edge
    always @(negedge clk_i) begin
        cov_last_fall = $time;
        cov_have_fall = 1;

        if ((rstn_i === 1'b1) && cov_have_data_change &&
        ($time == cov_last_data_change + 1ps))
            between_cov.sample(-1, 0);
    end
    // ----
    
    cg_disabled_hold hold_cov = new();
    cg_capture_sequence capture_cov = new();
    cg_reset_release release_cov = new();
    cg_reset reset_cov = new();
    cg_dff normal_cov = new();

//========================//
//          TASKS         //
//========================//

    // Change inputs halfway between rising clock edges.
    task automatic drive(input logic d_drive, input logic en_drive);
        @(negedge clk_i);
        d_i = d_drive;
        en_i = en_drive;
    endtask

    // Drive inputs and wait until the corresponding capture has settled.
    task automatic run_cycle(input logic data_value, input logic enable_value);
        drive(data_value, enable_value);
        @(posedge clk_i);
        #1ps;
    endtask

    task automatic reset_case(
        input logic prior_q,
        input logic data_value,
        input logic enable_value,
        input bit high_phase
    );
        // Establish the output before changing the reset controls.
        run_cycle(prior_q, 1'b1);
        if (!high_phase)
            @(negedge clk_i);
        #1ps;
        d_i = data_value;
        en_i = enable_value;
        #1ps;
        rstn_i = 0;

        // Hold through a rising edge and release between edges.
        @(posedge clk_i);
        @(negedge clk_i);
        #2ps;
        rstn_i = 1;
        repeat (2) @(posedge clk_i);
        #1ps;
    endtask

    task automatic report_coverage;
        real normal_pct, reset_pct, release_pct, capture_pct;
        real hold_pct, duration_pct, between_pct;
        normal_pct = normal_cov.get_inst_coverage();
        reset_pct = reset_cov.get_inst_coverage();
        release_pct = release_cov.get_inst_coverage();
        capture_pct = capture_cov.get_inst_coverage();
        hold_pct = hold_cov.get_inst_coverage();
        duration_pct = duration_cov.get_inst_coverage();
        between_pct = between_cov.get_inst_coverage();

        $display("Normal operation: %0.1f%%", normal_pct);
        $display("Reset assertion:  %0.1f%%", reset_pct);
        $display("Reset release:    %0.1f%%", release_pct);
        $display("Enabled captures: %0.1f%%", capture_pct);
        $display("Disabled holds:   %0.1f%%", hold_pct);
        $display("Reset duration:   %0.1f%%", duration_pct);
        $display("Between edges:    %0.1f%%", between_pct);

        if ((normal_pct < 100.0) || (reset_pct < 100.0) ||
            (release_pct < 100.0) || (capture_pct < 100.0) ||
            (hold_pct < 100.0) || (duration_pct < 100.0) ||
            (between_pct < 100.0))
            $fatal(1, "DFF coverage is incomplete");
    endtask

//========================//
//         STIMULUS       //
//========================//

    initial begin
        // Initialize under reset and hold it through two rising edges.
        rstn_i = 0;
        en_i = 0;
        d_i = 0;
        repeat (2) @(negedge clk_i);
        #2ps;
        rstn_i = 1;

        $display("TEST: all eight normal-operation combinations");
        for (int q = 0; q < 2; q++) begin
            for (int data_value = 0; data_value < 2; data_value++) begin
                for (int enable_value = 0; enable_value < 2; enable_value++) begin
                    run_cycle(bit'(q), 1'b1);
                    run_cycle(bit'(data_value), bit'(enable_value));
                end
            end
        end

        $display("TEST: consecutive enabled captures");
        run_cycle(0, 1);
        run_cycle(0, 1);
        run_cycle(1, 1);
        run_cycle(1, 1);
        run_cycle(0, 1);

        $display("TEST: disabled holds with toggling data");
        for (int q = 0; q < 2; q++) begin
            run_cycle(bit'(q), 1'b1);
            run_cycle(0, 0);
            run_cycle(1, 0);
            run_cycle(0, 0);
            run_cycle(1, 0);
        end

        $display("TEST: reset controls, clock phases, and recovery");
        for (int q = 0; q < 2; q++) begin
            for (int data_value = 0; data_value < 2; data_value++) begin
                for (int enable_value = 0; enable_value < 2; enable_value++) begin
                    for (int high_phase = 0; high_phase < 2; high_phase++) begin
                        reset_case(bit'(q), bit'(data_value),
                                   bit'(enable_value), bit'(high_phase));
                    end
                end
            end
        end

        $display("TEST: extended reset while data and enable change");
        run_cycle(1, 1);
        #1ps;
        rstn_i = 0;
        drive(0, 0);
        drive(1, 1);
        drive(0, 1);
        drive(1, 0);
        @(negedge clk_i);
        #2ps;
        rstn_i = 1;
        repeat (2) @(posedge clk_i);
        #1ps;

        $display("TEST: short reset pulses between rising edges");
        for (int q = 0; q < 2; q++) begin
            run_cycle(bit'(q), 1'b1);
            #1ps;
            rstn_i = 0;
            #2ps;
            rstn_i = 1;
            repeat (2) @(posedge clk_i);
            #1ps;
        end

        $display("TEST: data changes around falling edges");
        for (int q = 0; q < 2; q++) begin
            run_cycle(bit'(q), 1'b1);
            run_cycle(0, 0);
            #3ps; d_i = 1; // 1ps before the falling edge.
            #2ps; d_i = 0; // 1ps after the falling edge.
            @(posedge clk_i);
            #1ps;
        end

        $display("TEST: enable toggles without a rising clock edge");
        run_cycle(0, 0);
        #1ps; en_i = 1;
        #1ps; en_i = 0;

        // Allow the last operation's next-cycle assertion to complete.
        repeat (2) @(posedge clk_i);
        #1ps;
        report_coverage();
        $display("PASS: DFF checks completed with all coverage bins hit");
        $finish;
    end

    initial begin
        #10000ps;
        $fatal(1, "DFF testbench timed out");
    end

endmodule
