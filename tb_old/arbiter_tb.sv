`timescale 1ps/1ps

module arbiter_tb;

    parameter int WIDTH = 4;

    logic [WIDTH-1:0] req, grant;

    arbiter #(
        .WIDTH(WIDTH)
    ) dut (
        .req    (req),
        .grant  (grant)
    );

    task automatic check();
        for (int i = 0; i < 2**WIDTH; i++) begin
            req = i;
            #1;
        end
    endtask

    initial begin
        $monitor("req=%b grant=%b", req, grant);
        
        check();
        
        $finish;
    end

endmodule
