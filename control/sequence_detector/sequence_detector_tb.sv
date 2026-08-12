`timescale 1ps/1ps

module sequence_detector_tb;

    localparam SEQ_LEN = 4;
    localparam logic [SEQ_LEN-1:0] SEQ = 4'b1011;

    logic clk, rstn, in, out;

    sequence_detector #(
        .SEQ_LEN(SEQ_LEN), .SEQ(SEQ)
    ) dut (
        .clk    (clk),
        .rstn   (rstn),
        .in     (in),
        .out    (out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic seq_create();
        in = 1'b1; #10;
        in = 1'b0; #10;
        in = 1'b1; #20;
    endtask

    task automatic half_seq();
        in = 0; #10;
        in = 1; #20;
    endtask

    task automatic check();
        #1;
        if (out)
            $display("SEQUENCE DETECTED");
        #9;
    endtask

    initial begin
        $monitor("Time=%t in=%b, out=%b, seq_mem=%b",$time, in, out, dut.seq_mem);

        rstn = 0;
        in = 0;
        #5;
        rstn = 1;
        #5;

        seq_create();
        check();
        half_seq();
        check();

        $finish;
    end

endmodule
