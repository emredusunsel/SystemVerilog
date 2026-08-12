`timescale 1ps/1ps

module comparator_tb;

    localparam WIDTH = 8;

    logic [WIDTH-1:0] a, b;
    logic eq, gt, lt;

    comparator dut(
        .a  (a),
        .b  (b),
        .eq (eq),
        .gt (gt),
        .lt (lt)
    );

    task automatic fill(input logic [WIDTH-1:0] data_a, 
                        input logic [WIDTH-1:0] data_b);
        #5;

        a = data_a;
        b = data_b;

        #5;
    endtask

    task automatic check();
        $display("a=%b | b=%b || eq=%b gt=%b lt=%b",
                a, b, eq, gt, lt);
    endtask

    initial begin

        fill($urandom, $urandom);
        check();
        fill($urandom, $urandom);
        check();
        fill($urandom, $urandom);
        check();
        fill($urandom, $urandom);
        check();
        fill($urandom, $urandom);
        check();
        fill($urandom, $urandom);
        check();
        fill({WIDTH{1'b1}}, {WIDTH{1'b1}});
        check();
        fill({1'b1, $urandom}, $urandom);
        check();

        $finish;
    end

endmodule
