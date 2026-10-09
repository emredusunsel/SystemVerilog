`timescale 1ps/1ps

module register_tb;

    localparam int WIDTH = 8;
    localparam logic [WIDTH-1:0] RESET_VALUE = '0;

    localparam logic [WIDTH-1:0] MAX_VALUE = '1;

    logic clk_i, rstn_i, en_i;
    logic [WIDTH-1:0] in_i, out_o;

    register #(
        .WIDTH(WIDTH),
        .RESET_VALUE(RESET_VALUE)
    ) dut (
        .*
    );

    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

//============================//
//     REFERENCE MODEL        //
//============================//

    logic [WIDTH-1:0] expected_out;

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            expected_out <= RESET_VALUE;
        else if (en_i)
            expected_out <= in_i;
    end

//============================//
//        FUNCTIONS           //
//============================//

    function automatic logic [WIDTH-1:0] make_alternate(
        input bit lsb_value
    );
        for (int i = 0; i < WIDTH; i++) begin
            make_alternate[i] = lsb_value ^ ((i % 2) == 1);
        end
    endfunction

    localparam logic [WIDTH-1:0] ALT_VALUE_0 = make_alternate(0);
    localparam logic [WIDTH-1:0] ALT_VALUE_1 = make_alternate(1);

//============================//
//         PROPERTIES         //
//============================//

    property p_capture;
        @(posedge clk_i) disable iff (!rstn_i)
        en_i |=> (out_o == $past(in_i));
    endproperty

    property p_hold;
        @(posedge clk_i) disable iff (!rstn_i)
        !en_i |=> (out_o == $past(out_o));
    endproperty

    property p_capture_sequence;
        @(posedge clk_i) disable iff (!rstn_i)
        en_i
        ##1 (en_i && (in_i != $past(in_i)))
        ##1 (en_i && (in_i != $past(in_i)));
    endproperty

    property p_hold_sequence;
        @(posedge clk_i) disable iff (!rstn_i)
        !en_i
        ##1 (!en_i && (in_i != $past(in_i)))
        ##1 (!en_i && (in_i != $past(in_i)));
    endproperty

    property p_reset_release_capture;
        @(posedge clk_i) disable iff (!rstn_i)
        ($rose(rstn_i) && en_i) |=> (out_o == $past(in_i));
    endproperty

    property p_reset_release_hold;
        @(posedge clk_i) disable iff (!rstn_i)
        ($rose(rstn_i) && !en_i) |=> (out_o == RESET_VALUE);
    endproperty

//============================//
//         ASSERTIONS         //
//============================//

    always @(posedge clk_i or negedge rstn_i) begin
        #1;
        check_output: assert (expected_out === out_o)
            else $fatal(1, "REGISTER MISMATCH: t=%0t, rstn=%b, en=%b, in=%h, out=%h, expected=%h",
                        $time, rstn_i, en_i, in_i, out_o, expected_out);
    end

    always @(negedge rstn_i) begin
        #1;
        check_reset: assert (out_o === RESET_VALUE)
            else $fatal(1, "Async Reset Fail: t=%0t, out=%h, expected=%h",
                        $time, out_o, RESET_VALUE);
    end

    always @(posedge clk_i or negedge rstn_i) begin
        #1;
        if (!rstn_i && en_i && (in_i !== RESET_VALUE)) begin
            check_reset_priority: assert (out_o === RESET_VALUE)
                else $fatal(1, "Reset priority fail: t=%0t, out=%h, expected=%h",
                            $time, out_o, RESET_VALUE);
        end
    end

    a_capture: assert property (p_capture)
        else $fatal(1, "Enable capture fail @%0t: out=%h, _in=%0h",
                    $time, $sampled(out_o), $past(in_i));

    a_hold: assert property (p_hold)
        else $fatal(1, "Hold capture fail @%0t: out=%h, _out=%h",
                    $time, $sampled(out_o), $past(out_o));

    bit reset_seen = 0;

    always @(negedge rstn_i) reset_seen = 1;

    always @(posedge clk_i or negedge rstn_i) begin
        #1;

        if (reset_seen) begin
            check_output_known: assert (!$isunknown(out_o))
                else $fatal(1, "Unknown output: t=%0t, out=%h",
                            $time, out_o);
        end
    end

//============================//
//          COVERAGE          //
//============================//

    logic [WIDTH-1:0] prev_in, prev_out;
    bit data_changed = 0;
    bit output_changed = 0;
    bit word_history_valid = 0;

    bit capture_sequence_hit = 0;
    bit hold_sequence_hit = 0;
    bit reset_release_capture_hit = 0;
    bit reset_release_hold_hit = 0;

    covergroup cg_input @(posedge clk_i);
        cp_reset_value: coverpoint rstn_i {
            bins reset_value[] = {1'b0, 1'b1};
        }
        cp_enable_value: coverpoint en_i iff (rstn_i) {
            bins enable_value[] = {1'b0, 1'b1};
        }
        cp_data_value: coverpoint in_i iff (rstn_i) {
            bins data_max = {MAX_VALUE};
            bins data_zero = {'0};
            bins data_other = {[WIDTH'(1):(MAX_VALUE-WIDTH'(1))]};
        }
        cp_data_alternate: coverpoint in_i iff (rstn_i) {
            bins data_alternate[] = {ALT_VALUE_0, ALT_VALUE_1};
        }
        cp_output_value: coverpoint out_o iff (rstn_i) {
            bins out_max = {MAX_VALUE};
            bins out_zero = {'0};
            bins out_other = {[WIDTH'(1):(MAX_VALUE-WIDTH'(1))]};
        }
        cp_output_alternate: coverpoint out_o iff (rstn_i) {
            bins out_alternate[] = {ALT_VALUE_0, ALT_VALUE_1};
        }

        cx_enable_data: cross cp_enable_value, cp_data_value
            iff (rstn_i);
    endgroup

    covergroup cg_transition @(posedge clk_i);
        cp_reset_transition: coverpoint rstn_i {
            bins reset_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
        cp_enable_transition: coverpoint en_i iff (rstn_i) {
            bins enable_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
    endgroup

    covergroup cg_word_transition;
        cp_data_transition: coverpoint data_changed {
            bins data_transition[] = {1'b0, 1'b1};
        }
        cp_output_transition: coverpoint output_changed {
            bins output_transition[] = {1'b0, 1'b1};
        }
    endgroup

    cg_input input_cov = new();    
    cg_transition transition_cov = new();
    cg_word_transition word_transition_cov = new();

    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            word_history_valid = 0;
            data_changed = 0;
            output_changed = 0;
        end else begin
            if (word_history_valid) begin
                data_changed = (in_i !== prev_in);
                output_changed = (out_o !== prev_out);

                word_transition_cov.sample();
            end

            prev_in = in_i;
            prev_out = out_o;
            word_history_valid = 1;
        end
    end

    c_capture_sequence: cover property (p_capture_sequence)
        capture_sequence_hit = 1;
    c_hold_sequence:    cover property (p_hold_sequence)
        hold_sequence_hit = 1;
    c_reset_release_capture: cover property (p_reset_release_capture)
        reset_release_capture_hit = 1;
    c_reset_release_hold:    cover property (p_reset_release_hold)
        reset_release_hold_hit = 1;

//============================//
//           TASKS            //
//============================//

    task automatic drive(
        input logic [WIDTH-1:0] drive_in,
        input logic drive_en
    );
        @(negedge clk_i);
        in_i = drive_in;
        en_i = drive_en;
    endtask

    task automatic run_cycle(
        input logic [WIDTH-1:0] cycle_in,
        input logic cycle_en
    );
        drive(cycle_in, cycle_en);
        @(posedge clk_i);
        #1;
    endtask //automatic

    task automatic report_coverage;
        real input_pct, transition_pct, word_transition_pct;
        real property_pct;
        int unsigned property_hits;

        input_pct = input_cov.get_inst_coverage();
        transition_pct = transition_cov.get_inst_coverage();
        word_transition_pct = word_transition_cov.get_inst_coverage();

        property_hits = int'(capture_sequence_hit) +
                        int'(hold_sequence_hit) +
                        int'(reset_release_capture_hit) +
                        int'(reset_release_hold_hit);

        property_pct = 25.0 * property_hits;

        $display("\nCoverage Report:");
        $display("------------------------");

        $display("Input operation:                   %0.2f%%", input_pct);
        $display("Reset/enable changes:              %0.2f%%", transition_pct);
        $display("Word changes:                      %0.2f%%", word_transition_pct);
        $display("Cover properties:                  %0.2f%% (%0d/4)",
                property_pct, property_hits);

        $display("\tCapture sequence hit:      %0b",
                 capture_sequence_hit);
        $display("\tHold sequence hit:         %0b",
                 hold_sequence_hit);
        $display("\tReset-release capture hit: %0b",
                 reset_release_capture_hit);
        $display("\tReset-release hold hit:    %0b",
                 reset_release_hold_hit);


        if ((input_pct < 100.00) ||
            (transition_pct < 100.00) ||
            (word_transition_pct < 100.00) ||
            (property_hits != 4)) begin
            $fatal(1, "Register Coverage Incomplete");
        end else
            $display("PASS: All covergroup bins and cover-property targets hit\n");  
    endtask

//============================//
//          STIMILUS          //
//============================//

    initial begin
        $display("=========================");
        $display("  Register Checks Begin");
        $display("=========================");
        rstn_i = 0;
        en_i = 0;
        in_i = '0;
        repeat (2) @(posedge clk_i);
        @(negedge clk_i);
        rstn_i = 1;

        run_cycle('0, 1);   // Load Zero
        run_cycle('1, 1);   // Load all ones
        repeat (10) begin
            run_cycle((WIDTH'($urandom_range(1, WIDTH'('1)))), 1); // Load random values
        end

        run_cycle(ALT_VALUE_0, 1);  // Capture AA
        run_cycle(ALT_VALUE_1, 1);  // Capture 55

        run_cycle(MAX_VALUE, 0);    // Disabled + all ones
        run_cycle(WIDTH'(1), 0);
        run_cycle(WIDTH'(2), 0);
        run_cycle(WIDTH'(1), 0);    // Disabled + other

        @(negedge clk_i);
        en_i = 1;
        in_i = ALT_VALUE_0;

        #2;
        rstn_i = 0; // Assert reset between clock edges.

        repeat (2) @(posedge clk_i);

        @(negedge clk_i);
        rstn_i = 1; // Enable is already HIGH

        // First edge captures; second completes the cover property
        repeat (2) @(posedge clk_i);
        #1;

        report_coverage();
        $display("=========================");
        $display("  Register Checks End");
        $display("=========================");
        $finish;
    end

    initial begin
        #20000;
        $fatal(1, "Timeout");
    end

endmodule
