`timescale 1ns/1ps

module assertions_tb;

    // ============================================================
    // Clock
    // ============================================================

    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;


    // ============================================================
    // Signals
    //
    // There is NO DUT.
    // We are simply generating signals and checking them.
    // ============================================================

    logic req;
    logic ack;
    logic [3:0] count;


    // ============================================================
    // Stimulus
    // ============================================================

    initial begin

        req   = 0;
        ack   = 0;
        count = 0;

        // --------------------------------------------------------
        // Basic assertion
        //
        // At time 0, req should be 0.
        // This assertion should PASS.
        // --------------------------------------------------------

        assert (req == 0)
            else $error("REQ should be 0");


        // --------------------------------------------------------
        // Change signals
        // --------------------------------------------------------

        #10;

        req = 1;
        ack = 1;

        // --------------------------------------------------------
        // This assertion should PASS.
        // --------------------------------------------------------

        assert (req == 1)
            else $error("REQ is not 1");

        assert (ack == 1)
            else $error("ACK is not 1");


        // --------------------------------------------------------
        // Intentional failure
        //
        // req is currently 1, so this assertion is FALSE.
        //
        // The simulator should print our error message.
        // --------------------------------------------------------

        assert (req == 0)
            else $error("INTENTIONAL FAILURE: REQ is not 0");


        // --------------------------------------------------------
        // Test a vector
        // --------------------------------------------------------

        count = 5;

        assert (count < 10)
            else $error("COUNT is too large");


        // --------------------------------------------------------
        // Intentional failure with a vector
        // --------------------------------------------------------

        assert (count == 3)
            else $error("INTENTIONAL FAILURE: COUNT is not 3");


        #10;

        $display("");
        $display("================================");
        $display("Assertion TB finished");
        $display("================================");

        $finish;

    end


    // ============================================================
    // Assertions inside an always block
    // ============================================================
    //
    // This is where immediate assertions become useful for
    // checking something continuously.
    //
    // Every rising edge of clk:
    //
    //     count must be <= 15
    //
    // Since count is 4 bits, this should always pass.
    // ============================================================

    always @(posedge clk) begin

        assert (count <= 15)
            else $error("COUNT exceeded maximum value");

    end


    // ============================================================
    // Another continuously checked condition
    //
    // Protocol rule:
    //
    //     ACK cannot be high unless REQ is high.
    //
    // Therefore:
    //
    //     req = 0, ack = 1  -> FAIL
    //     req = 1, ack = 1  -> PASS
    // ============================================================

    always @(posedge clk) begin

        assert (!(ack && !req))
            else $error("PROTOCOL ERROR: ACK is high without REQ");

    end

endmodule