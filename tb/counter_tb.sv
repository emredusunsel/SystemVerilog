`timescale 1ps/1ps

module counter_tb;

    localparam int WIDTH = 4;

    logic clk_i, rstn_i, en_i, dir_i;
    logic [WIDTH-1:0] q_o;

    counter dut (
        .*
    );

    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

//============================//
//         PROPERTIES         //
//============================//

    property p_hold_disabled;
        @(posedge clk_i) disable iff (!rstn_i)
        !en_i |=> (q_o == $past(q_o));
    endproperty

    property p_count_up;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && (dir_i == 1'b0)) |=> (q_o == $past(q_o) + 1'b1);  // width limit wraparound check
    endproperty

    property p_count_down;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && (dir_i == 1'b1)) |=> (q_o == $past(q_o) - 1'b1); // width limit wraparound check
    endproperty

    property p_dir_change_ud;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && !dir_i)
        ##1 (en_i && dir_i);
    endproperty

    property p_dir_change_du;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && dir_i)
        ##1 (en_i && !dir_i);
    endproperty

    property p_up_wrap;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && !dir_i && (q_o == '1)) |=> (q_o == '0);
    endproperty

    property p_down_wrap;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i && dir_i && (q_o == '0)) |=> (q_o == '1);
    endproperty

//============================//
//        REFERENCE MODEL     //
//============================//

    localparam int unsigned MODULUS = 2 ** WIDTH;
    int unsigned expected_count;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            expected_count = 0;
        else if (en_i)
            expected_count = (expected_count + (dir_i ? MODULUS - 1 : 1)) % MODULUS;
    end

//============================//
//          COVERAGE          //
//============================//

    bit dir_change_ud_hit = 0;
    bit dir_change_du_hit = 0;
    bit reset_during_count_hit = 0;
    bit up_wrap_hit = 0;
    bit down_wrap_hit = 0;

    covergroup cg_input @(posedge clk_i);
        cp_reset_value: coverpoint rstn_i {
            bins reset_value[] = {1'b0, 1'b1};
        }

        cp_enable_value: coverpoint en_i iff (rstn_i) {
            bins enable_value[] = {1'b0, 1'b1};
        }

        cp_dir_value: coverpoint dir_i iff (rstn_i) {
            bins dir_value[] = {1'b0, 1'b1};
        }
    endgroup

    covergroup cp_count_value @(posedge clk_i);
        cp_coun_value: coverpoint q_o iff (rstn_i) {
            bins count_value[] = {['0:'1]};
        }
    endgroup
    

    covergroup cg_transition @(posedge clk_i);
        cg_enable_transition: coverpoint en_i iff (rstn_i) {
            bins cp_enable_hc = (1'b0 => 1'b1);
            bins cp_enable_ch = (1'b1 => 1'b0);
        }
    endgroup
    
    cp_count_value count_value_cov = new();
    cg_transition transition_cov = new();
    cg_input input_cov = new();

    c_dir_change_ud: cover property (p_dir_change_ud)
        dir_change_ud_hit = 1;
    c_dir_change_du: cover property (p_dir_change_du)
        dir_change_du_hit = 1;
    c_up_wrap: cover property (p_up_wrap)
        up_wrap_hit = 1;
    c_down_wrap: cover property (p_down_wrap)
        down_wrap_hit = 1;

    always @(negedge rstn_i) begin
        if (en_i && !$isunknown(q_o) && (q_o != '0)) begin
            #1;
            if (q_o === '0)
                reset_during_count_hit = 1;
        end
    end

//============================//
//         ASSERTIONS         //
//============================//

    always @(posedge clk_i or negedge rstn_i) begin
        #1;
        check_ref_model: assert (q_o === WIDTH'(expected_count))
            else $fatal(1, "Counter Mismatch @%0t: expected=%0d, got=%0d",
                        $time, expected_count, q_o);
    end

    always @(negedge rstn_i) begin
        #1;
        check_async_reset: assert (q_o === '0)
            else $fatal(1, "Asynchronous reset fail @%0t: q_o=%0d while expecting 0",
                        $time, q_o);
    end

    always @(posedge clk_i) begin
        #1;
        if (!rstn_i && en_i) begin
            check_reset_priority: assert (q_o === '0)
                else $fatal(1, "Reset priority fail @%0t: q_o=%d while expecting 0",
                            $time, q_o);
        end
    end

    a_hold_disabled: assert property (p_hold_disabled)
        else $fatal(1, "@%0t: Hold when Disabled failed: q_o=%0d, _q_o=%0d",
                    $time, q_o, $past(q_o));

    a_count_up: assert property (p_count_up)
        else $fatal(1, "@%0t: Count up failed: q_o=%0d, _q_o=%0d",
                    $time, q_o,  $past(q_o));

    a_count_down: assert property (p_count_down)
        else $fatal(1, "@%0t: Count down failed: q_o=%0d, _q_o=%0d",
                    $time, q_o,  $past(q_o));

//============================//
//           TASKS            //
//============================//

    task automatic count_up_down(
        int unsigned cycle,
        logic drive_en,
        logic drive_dir
    );
        repeat (cycle) begin
            @(negedge clk_i);
            en_i = drive_en;
            dir_i = drive_dir;
        end
    endtask

    task automatic report_coverage;
        real input_pct, transition_pct, count_value_pct;
        real property_pct;
        real property_hits;

        input_pct = input_cov.get_inst_coverage();
        count_value_pct = count_value_cov.get_inst_coverage();
        transition_pct = transition_cov.get_inst_coverage();

        property_hits = int'(dir_change_ud_hit) +
                        int'(dir_change_du_hit) +
                        int'(reset_during_count_hit) +
                        int'(up_wrap_hit) +
                        int'(down_wrap_hit);

        property_pct = (property_hits / 5.00) * 100.00;

        $display("\nCoverage Report:");
        $display("------------------------");

        $display("Input operation:        %0.2f%%", input_pct);
        $display("Count value operation:  %0.2f%%", count_value_pct);
        $display("Transitions:            %0.2f%%", transition_pct);
        $display("Cover properties:       %0.2f%% (%0.0f/5)",
                property_pct, property_hits);

        $display("\tDir change U->D hit:        %0b",
                 dir_change_ud_hit);
        $display("\tDir change D->U hit:        %0b",
                 dir_change_du_hit);
        $display("\tReset during count hit:     %0b",
                 reset_during_count_hit);
        $display("\tUp wrap hit:                %0b",
                 up_wrap_hit);
        $display("\tDown wrap hit:              %0b",
                 down_wrap_hit);


        if ((input_pct < 100.00) ||
            (count_value_pct < 100.00) ||
            (transition_pct < 100.00) ||
            (property_hits != 5)) begin
            $fatal(1, "Counter Coverage Incomplete");
        end else
            $display("PASS: All covergroup bins and cover-property targets hit\n");  
    endtask

//============================//
//          STIMILUS          //
//============================//

    initial begin
        $display("=========================");
        $display("  Counter Checks Begin");
        $display("=========================");
        rstn_i = 0;
        en_i = 0;
        dir_i = 0;
        repeat (2) @(negedge clk_i);
        rstn_i = 1;
        @(negedge clk_i);
        
        // Count up through a full cycle
        count_up_down(16, 1, 0);
        // Count down through a full cycle
        count_up_down(16, 1, 1);
        // Hold in both directions
        count_up_down(5, 0, 0);
        count_up_down(5, 0, 1);
        // Change direction while enabled
        count_up_down(1, 1, 0);
        count_up_down(1, 1, 1);
        count_up_down(1, 1, 0);
        count_up_down(1, 1, 1);
        // Reset during counting
        count_up_down(1, 1, 0);
        wait (q_o != '0)
        @(negedge clk_i);
        rstn_i = 0;
        // Reset priority
        @(negedge clk_i);
        en_i = 1;
        repeat (4) @(negedge clk_i);
        // Reset release
        rstn_i = 1;
        en_i = 0;
        #20;
        report_coverage();
        $display("=========================");
        $display("  Counter Checks End");
        $display("=========================");
        $finish;
    end

    // initial begin
    //     $dumpfile("wave.vcd");
    //     $dumpvars(0, counter_tb);
    // end

    initial begin
        #20000;
        $fatal(1, "Timeout");
    end

endmodule
