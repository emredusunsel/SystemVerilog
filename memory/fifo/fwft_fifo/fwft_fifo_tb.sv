`timescale 1ps/1ps

module fwft_fifo_tb;

    localparam int WIDTH = 4;
    localparam int DEPTH = 4;

    logic clk, rstn, wr_en;
    logic [WIDTH-1:0] wr_data;
    logic rd_en;
    logic [WIDTH-1:0] rd_data;
    logic full, empty;

    fwft_fifo #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk        (clk),
        .rstn       (rstn),
        .wr_en      (wr_en),
        .wr_data    (wr_data),
        .rd_en      (rd_en),
        .rd_data    (rd_data),
        .full       (full),
        .empty      (empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic write_fifo(logic [WIDTH-1:0] data);
        @(negedge clk);
        wr_en   = 1;
        wr_data = data;
        @(negedge clk);
        wr_en   = 0;
    endtask

    task automatic read_fifo();
        @(negedge clk);
        rd_en = 1;
        @(negedge clk);
        rd_en = 0;
    endtask

    initial begin
        rstn = 0;
        wr_data = '0;
        wr_en   = 0;
        rd_en   = 0;
        #10;
        rstn = 1;
        @(negedge clk);

        write_fifo(4'd1);
        @(negedge clk);
        read_fifo();
        
        #10;

        $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, fwft_fifo_tb);
    end

endmodule
