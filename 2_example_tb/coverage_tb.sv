`timescale 1ns/1ps

module coverage_tb;

    // ============================================================
    // Signal we want to measure
    //
    // Imagine this is an ALU operation:
    //
    // 0 = ADD
    // 1 = SUB
    // 2 = AND
    // 3 = OR
    // ============================================================

    logic [1:0] op;


    // ============================================================
    // Coverage bins
    //
    // Each bit tells us whether that value has occurred.
    //
    // op_hit[0] = Did ADD happen?
    // op_hit[1] = Did SUB happen?
    // op_hit[2] = Did AND happen?
    // op_hit[3] = Did OR happen?
    // ============================================================

    logic [3:0] op_hit;


    integer i;
    integer hit;


    // ============================================================
    // TEST
    // ============================================================

    initial begin

        // Nothing has been tested yet
        op_hit = 4'b0000;


        // --------------------------------------------------------
        // Generate stimulus
        // --------------------------------------------------------

        for (i = 0; i < 20; i = i + 1) begin

            // Generate random operation
            op = $urandom_range(0, 3);

            // Record that this operation occurred
            op_hit[op] = 1'b1;

        end


        // ========================================================
        // Calculate coverage
        // ========================================================

        hit = 0;

        for (i = 0; i < 4; i = i + 1) begin

            if (op_hit[i])
                hit++;

        end


        // ========================================================
        // Print results
        // ========================================================

        $display("");
        $display("==============================");
        $display("       COVERAGE REPORT");
        $display("==============================");

        $display("ADD : %s", op_hit[0] ? "HIT" : "MISS");
        $display("SUB : %s", op_hit[1] ? "HIT" : "MISS");
        $display("AND : %s", op_hit[2] ? "HIT" : "MISS");
        $display("OR  : %s", op_hit[3] ? "HIT" : "MISS");

        $display("------------------------------");

        $display("Coverage: %0d / 4 = %0.2f%%",
                 hit,
                 (hit * 100.0) / 4);

        $display("==============================");

        $finish;

    end

endmodule