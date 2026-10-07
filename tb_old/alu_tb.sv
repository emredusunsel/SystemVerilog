`timescale 1ns/1ps

module alu_tb;

    localparam int WIDTH = 8;

    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    alu_op_t          op;

    logic [WIDTH-1:0] out;
    logic             zero;
    logic             carry;
    logic             of;
    logic             neg;

    alu #(
        .WIDTH(WIDTH)
    ) dut (
        .a     (a),
        .b     (b),
        .op    (op),
        .out   (out),
        .zero  (zero),
        .carry (carry),
        .of    (of),
        .neg   (neg)
    );

    integer i = 0;

    task automatic check(
        input alu_op_t          test_op,
        input logic [WIDTH-1:0] test_a,
        input logic [WIDTH-1:0] test_b,
        input logic [WIDTH-1:0] expected_out,
        input logic             expected_carry,
        input logic             expected_of
    );
        begin
            a  = test_a;
            b  = test_b;
            op = test_op;

            #1;

            if (out !== expected_out ||
                carry !== expected_carry ||
                of !== expected_of) begin

                $display("FAIL: op=%s a=%h b=%h | out=%h carry=%b of=%b",
                         test_op.name(), a, b, out, carry, of);

                $display("      expected: out=%h carry=%b of=%b",
                         expected_out, expected_carry, expected_of);

                $fatal;
            end

            if (zero !== (expected_out == '0)) begin
                $display("FAIL: zero flag incorrect");
                $fatal;
            end

            if (neg !== expected_out[WIDTH-1]) begin
                $display("FAIL: neg flag incorrect");
                $fatal;
            end

            $display("TEST %0d PASS: op=%s a=%h b=%h | out=%h carry=%b of=%b zero=%b neg=%b",
                     i, test_op.name(), a, b,
                     out, carry, of, zero, neg);
        end

        i = i + 1;
    endtask


    initial begin

        // ----------------
        // ADD
        // ----------------

        check(ADD_OP, 8'h05, 8'h03, 8'h08, 1'b0, 1'b0);     // TEST 0

        // Carry: 255 + 1 = 256
        check(ADD_OP, 8'hFF, 8'h01, 8'h00, 1'b1, 1'b0);     // TEST 1

        // Signed overflow: 127 + 1 = -128
        check(ADD_OP, 8'h7F, 8'h01, 8'h80, 1'b0, 1'b1);     // TEST 2

        // ----------------
        // SUB
        // ----------------

        check(SUB_OP, 8'h08, 8'h03, 8'h05, 1'b1, 1'b0);     // TEST 3

        // 3 - 8 = -5
        check(SUB_OP, 8'h03, 8'h08, 8'hFB, 1'b0, 1'b0);     // TEST 4

        // Signed overflow: 127 - (-1) = 128
        check(SUB_OP, 8'h7F, 8'hFF, 8'h80, 1'b0, 1'b1);     // TEST 5

        // ----------------
        // LOGICAL
        // ----------------

        check(AND_OP, 8'hAA, 8'h0F, 8'h0A, 1'b0, 1'b0);     // TEST 6

        check(OR_OP,  8'hA0, 8'h0F, 8'hAF, 1'b0, 1'b0);     // TEST 7

        check(XOR_OP, 8'hAA, 8'hFF, 8'h55, 1'b0, 1'b0);     // TEST 8

        // ----------------
        // SHIFTS
        // ----------------

        // 0000_0011 << 2 = 0000_1100
        check(SLL_OP, 8'h03, 8'h02, 8'h0C, 1'b0, 1'b0);     // TEST 9

        // 1000_0000 >> 2 = 0010_0000
        check(SRL_OP, 8'h80, 8'h02, 8'h20, 1'b0, 1'b0);     // TEST 10

        // Arithmetic right shift:
        // 1000_0000 >>> 2 = 1110_0000
        check(SRA_OP, 8'h80, 8'h02, 8'hE0, 1'b0, 1'b0);     // TEST 11

        // ----------------
        // SLT signed
        // ----------------

        // 5 < 10
        check(SLT_OP, 8'h05, 8'h0A, 8'h01, 1'b0, 1'b0);     // TEST 12

        // -5 < 3
        check(SLT_OP, 8'hFB, 8'h03, 8'h01, 1'b0, 1'b0);     // TEST 13

        // 5 < -3 is false
        check(SLT_OP, 8'h05, 8'hFD, 8'h00, 1'b0, 1'b0);     // TEST 14

        // ----------------
        // SLTU unsigned
        // ----------------

        // 5 < 10
        check(SLTU_OP, 8'h05, 8'h0A, 8'h01, 1'b0, 1'b0);     // TEST 15

        // 255 < 1 is false unsigned
        check(SLTU_OP, 8'hFF, 8'h01, 8'h00, 1'b0, 1'b0);     // TEST 16

        // 1 < 255
        check(SLTU_OP, 8'h01, 8'hFF, 8'h01, 1'b0, 1'b0);     // TEST 17

        // ----------------
        // ZERO FLAG
        // ----------------

        check(AND_OP, 8'hF0, 8'h0F, 8'h00, 1'b0, 1'b0);     // TEST 18

        $display("");
        $display("====================");
        $display("     ALL TESTS PASS");
        $display("====================");

        $finish;
    end

endmodule
