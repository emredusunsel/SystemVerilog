`timescale 1ps/1ps

module shift_register_tb #(
    parameter int WIDTH = 8
);

    logic clk_i, rstn_i, en_i, serial_i, dir_i;
    logic [WIDTH-1:0] q_o;

    shift_register #(
        .WIDTH(WIDTH)
    ) dut (
        .*
    );

    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

    initial begin
        rstn_i = 0;
        en_i = 0;
        serial_i = 0;
        dir_i = 0;
        repeat (2) @(negedge clk_i);
        rstn_i = 1;
        #20;
        $finish;
    end

    initial begin
        #200000;
        $fatal(1, "Timeout");
    end

endmodule
