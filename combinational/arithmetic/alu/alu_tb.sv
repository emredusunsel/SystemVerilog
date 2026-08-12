`timescale 1ns/1ps

module alu_tb;

    localparam int WIDTH = 8;

    logic [WIDTH-1:0] a, b;
    alu_op_t          op;
    logic [WIDTH-1:0] out;
    logic zero, carry, of, neg;

    alu #(
        .WIDTH(WIDTH)
    ) dut (
        .a    (a),
        .b    (b),
        .op   (op),
        .out  (out),
        .zero (zero),
        .carry(carry),
        .of   (of),
        .neg  (neg)
    );

    task automatic check(
        input logic [WIDTH-1:0] expected_out,
        input logic             expected_zero,
        input logic             expected_carry,
        input logic             expected_of,
        input logic             expected_neg
    );
        begin
            #1;

            if ((out   !== expected_out)   ||
                (zero  !== expected_zero)  ||
                (carry !== expected_carry) ||
                (of    !== expected_of)    ||
                (neg   !== expected_neg)) begin

                $display("FAIL: op=%s a=%h b=%h",
                         op.name(), a, b);

                $display("      OUT=%h ZERO=%b CARRY=%b OF=%b NEG=%b",
                         out, zero, carry, of, neg);

                $display("EXPECTED: OUT=%h ZERO=%b CARRY=%b OF=%b NEG=%b",
                         expected_out,
                         expected_zero,
                         expected_carry,
                         expected_of,
                         expected_neg);

                $fatal;
            end

            $display("PASS: op=%s a=%h b=%h -> out=%h zero=%b carry=%b of=%b neg=%b",
                     op.name(), a, b, out, zero, carry, of, neg);
        end
    endtask


    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, alu_tb);

        // --------------------------------------------------
        // ADD
        // --------------------------------------------------

        // 5 + 3 = 8
        a  = 8'd5;
        b  = 8'd3;
        op = ADD_OP;
        check(8'd8, 1'b0, 1'b0, 1'b0, 1'b0);

        // 255 + 1 = 0, carry
        a  = 8'hFF;
        b  = 8'h01;
        op = ADD_OP;
        check(8'h00, 1'b1, 1'b1, 1'b0, 1'b0);

        // 127 + 1 = -128 -> signed overflow
        a  = 8'h7F;
        b  = 8'h01;
        op = ADD_OP;
        check(8'h80, 1'b0, 1'b0, 1'b1, 1'b1);

        // -128 + (-1) = 127 -> signed overflow
        a  = 8'h80;
        b  = 8'hFF;
        op = ADD_OP;
        check(8'h7F, 1'b0, 1'b1, 1'b1, 1'b0);


        // --------------------------------------------------
        // SUB
        // --------------------------------------------------

        // 5 - 3 = 2
        a  = 8'd5;
        b  = 8'd3;
        op = SUB_OP;
        check(8'd2, 1'b0, 1'b1, 1'b0, 1'b0);

        // 3 - 5 = -2
        a  = 8'd3;
        b  = 8'd5;
        op = SUB_OP;
        check(8'hFE, 1'b0, 1'b0, 1'b0, 1'b1);

        // 127 - (-1) = 128 -> signed overflow
        a  = 8'h7F;
        b  = 8'hFF;
        op = SUB_OP;
        check(8'h80, 1'b0, 1'b0, 1'b1, 1'b1);

        // -128 - 1 = 127 -> signed overflow
        a  = 8'h80;
        b  = 8'h01;
        op = SUB_OP;
        check(8'h7F, 1'b0, 1'b1, 1'b1, 1'b0);

        // 5 - 5 = 0
        a  = 8'd5;
        b  = 8'd5;
        op = SUB_OP;
        check(8'h00, 1'b1, 1'b1, 1'b0, 1'b0);


        // --------------------------------------------------
        // AND
        // --------------------------------------------------

        a  = 8'hAA;
        b  = 8'h0F;
        op = AND_OP;
        check(8'h0A, 1'b0, 1'b0, 1'b0, 1'b0);


        // --------------------------------------------------
        // OR
        // --------------------------------------------------

        a  = 8'hA0;
        b  = 8'h0F;
        op = OR_OP;
        check(8'hAF, 1'b0, 1'b0, 1'b0, 1'b1);


        // --------------------------------------------------
        // XOR
        // --------------------------------------------------

        a  = 8'hAA;
        b  = 8'hFF;
        op = XOR_OP;
        check(8'h55, 1'b0, 1'b0, 1'b0, 1'b0);


        // --------------------------------------------------
        // NOT
        // --------------------------------------------------

        a  = 8'h00;
        b  = 8'h00;
        op = NOT_OP;
        check(8'hFF, 1'b0, 1'b0, 1'b0, 1'b1);


        // --------------------------------------------------
        // SHIFT LEFT
        // --------------------------------------------------

        a  = 8'b0000_0001;
        b  = 8'd2;
        op = SHL_OP;
        check(8'b0000_0100, 1'b0, 1'b0, 1'b0, 1'b0);


        // --------------------------------------------------
        // SHIFT RIGHT
        // --------------------------------------------------

        a  = 8'b1000_0000;
        b  = 8'd2;
        op = SHR_OP;
        check(8'b0010_0000, 1'b0, 1'b0, 1'b0, 1'b0);


        // --------------------------------------------------
        // ZERO RESULT
        // --------------------------------------------------

        a  = 8'hAA;
        b  = 8'hAA;
        op = XOR_OP;
        check(8'h00, 1'b1, 1'b0, 1'b0, 1'b0);


        $display("");
        $display("================================");
        $display("       ALL TESTS PASSED");
        $display("================================");

        $finish;
    end

endmodule
