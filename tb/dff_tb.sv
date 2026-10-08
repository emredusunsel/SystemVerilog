`timescale 1ps/1ps

module dff_tb;

    logic clk_i, rstn_i, en_i, d_i, q_o;

    dff dut (
        .*
    );

    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

//============================//
//         PROPERTIES         //
//============================//

    property p_capture;
        @(posedge clk_i) disable iff (!rstn_i)
        (en_i) |=> (q_o == $past(d_i));
    endproperty

    property p_hold;
        @(posedge clk_i) disable iff (!rstn_i)
        (!en_i) |=> (q_o == $past(q_o));
    endproperty

//============================//
//        REFERENCE MODEL     //
//============================//

    logic expected_q;
    always @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i)
            expected_q <= 1'b0;
        else if (en_i)
            expected_q <= d_i;
    end

//============================//
//          COVERAGE          //
//============================//

    // Input Coverage
    covergroup cg_input @(posedge clk_i);
        cp_reset_value: coverpoint rstn_i {
            bins reset_value[] = {1'b0, 1'b1};
        }
        cp_enable_value: coverpoint en_i {
            bins enable_value[] = {1'b0, 1'b1};
        }
        cp_data_value: coverpoint d_i {
            bins data_value[] = {1'b0, 1'b1};
        }
        cp_output_value: coverpoint q_o {
            bins output_value[] = {1'b0, 1'b1};
        }

        cx_reset_enable_data: cross cp_reset_value, cp_enable_value, cp_data_value;
        cx_enable_data_output: cross cp_enable_value, cp_data_value, cp_output_value 
            iff (rstn_i);
    endgroup

    // Transition Coverage
    covergroup cg_transition @(posedge clk_i);
        cp_reset_transition: coverpoint rstn_i {
            bins reset_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
        cp_enable_transition: coverpoint en_i iff (rstn_i) {
            bins enable_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
        cp_data_transition: coverpoint d_i iff (rstn_i) {
            bins data_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
        cp_output_transition: coverpoint q_o iff (rstn_i) {
            bins output_transition[] = (1'b0, 1'b1 => 1'b0, 1'b1);
        }
    endgroup
    
    cg_transition transition_cov = new();
    cg_input input_cov = new();

//============================//
//         ASSERTIONS         //
//============================//

    always @(posedge clk_i or negedge rstn_i) begin
        #1;
        check_output: assert (q_o === expected_q)
            else $fatal(1, "DFF MISMATCH: t=%0t, rstn=%b, en=%b, d=%b, expected=%b, actual=%b",
                        $time, rstn_i, en_i, d_i, expected_q, q_o);
    end

    a_capture: assert property (p_capture)
        else $fatal(1, "@t=%0t: Capture failed. q=%b sampled_d=%b",
                        $time, q_o, $past(d_i));

    a_hold: assert property (p_hold)
        else $fatal(1, "@t=%0t: Hold failed. q=%b sampled_q=%b",
                        $time, q_o, $past(q_o));

//============================//
//            TASK            //
//============================//

    task automatic drive(
        input logic drive_d,
        input logic drive_en
    );
        @(negedge clk_i);
        d_i = drive_d;
        en_i = drive_en;
    endtask

    task automatic run_cycle(
        input logic data_value,
        input logic enable_value
    );
        drive(data_value, enable_value);
        @(posedge clk_i);
        #1;        
    endtask

    task automatic random_test(int unsigned repetition);
        repeat (repetition) begin
            @(negedge clk_i);

            rstn_i = ($urandom_range(0, 9) != 0);
            en_i = 1'($urandom_range(0, 1));
            d_i = 1'($urandom_range(0, 1));
        end
        $display("Random Tests Done");
    endtask

    task automatic report_coverage;
        real input_pct, transition_pct;

        input_pct      = input_cov.get_inst_coverage();
        transition_pct = transition_cov.get_inst_coverage();

        $display("\nCoverage Report:");
        $display("-----------------------------");
        $display("Input operation:      %0.2f%%", input_pct);
        $display("Transition operation: %0.2f%%", transition_pct);

        if ((input_pct < 100.00) || (transition_pct < 100.00))
            $fatal(1, "DFF Coverage incomplete");
        else
            $display("PASS: DFF checks completed with all coverage bins hit\n");            
    endtask

//============================//
//          STIMILUS          //
//============================//

    initial begin
        $display("=========================");
        $display("    DFF Checks Begin");
        $display("=========================");
        rstn_i = 0;
        en_i = 0;
        d_i = 0;
        repeat (2) @(negedge clk_i);
        rstn_i = 1;
        repeat (2) @(negedge clk_i);
        run_cycle(0, 1);    // Capture 0
        run_cycle(0, 0);    // Hold 0
        run_cycle(1, 1);    // Capture 1
        run_cycle(0, 0);    // Hold 1
        // Toggle enable:
        run_cycle(1, 0);
        run_cycle(1, 1);
        run_cycle(0, 0);
        run_cycle(1, 0);    // Data toggle with disabled
        run_cycle(1, 1);
        // Continuous capture:
        run_cycle(0, 1);
        run_cycle(1, 1);
        run_cycle(0, 1);
        run_cycle(1, 1);
        @(negedge clk_i);
        rstn_i = 0;         // Assert reset while q_o == 1
        @(negedge clk_i);
        rstn_i = 1;
        run_cycle(0, 1);
        @(negedge clk_i);
        rstn_i = 0;         // Assert reset while q_o == 0
        @(negedge clk_i);
        rstn_i = 1;
        run_cycle(1, 1);
        run_cycle(1, 0);
        @(negedge clk_i);
        rstn_i = 0;         // Assert reset while en_i == 0 && q_i == 1
        @(negedge clk_i);
        rstn_i = 1;
        run_cycle(0, 1);
        run_cycle(0, 0);
        @(negedge clk_i);
        rstn_i = 0;         // Assert reset while en_i == 0 && q_i == 0
        @(negedge clk_i);
        rstn_i = 1;
        @(negedge clk_i);
        random_test(1000);
        #10;
        report_coverage();
        $display("=========================");
        $display("    DFF Checks End");
        $display("=========================");
        $finish;
    end

    initial begin
        #50000ps;
        $fatal(1, "DFF testbench timed out");
    end

endmodule
