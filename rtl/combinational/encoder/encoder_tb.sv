`timescale 1ps/1ps

module encoder_tb;

    localparam WIDTH = 8;

    logic [WIDTH-1:0] data;
    logic [$clog2(WIDTH)-1:0] encoded;
    logic valid;

    encoder dut(
        .data   (data),
        .encoded(encoded),
        .valid  (valid)
    );

    task automatic check(logic [$clog2(WIDTH)-1:0] expected);
        if (encoded == expected)
            $display("PASS: data=%b, encoded=%d, valid=%b", data, encoded, valid);
        else
            $display("FAIL: expected=%d, encoded=%d, data=%b", expected, encoded, data);
    endtask

    initial begin

        // Apply test vectors
        for (int i = 0; i < 8; i++) begin
            data = 8'b1 << i;
            #1;
            check(i);
        end
        
        data = 8'b01010101; #1;
        check(6);
        data = 8'b00010011; #1;
        check(4);
        data = '0; #1;
        check(0);
        if(!valid)
            $display("VALID PASS");
        else
            $display("FAIL: VALID");

        $finish;
    end

endmodule
