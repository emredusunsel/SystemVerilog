`timescale 1ps/1ps

module decoder_tb;

    localparam WIDTH = 8;
    localparam DEPTH = $clog2(WIDTH);

    logic [DEPTH-1:0] addr;
    logic en;
    logic [WIDTH-1:0] y;

    decoder #(
        .WIDTH(WIDTH), .DEPTH(DEPTH)
    ) dut (
        .addr   (addr),
        .en     (en),
        .y      (y)
    );

    initial begin
        // Print values whenever they change
        $display("Time\t addr en  y");
        $monitor("%0t\t  %d    %d  %b", $time, addr, en, y);

        // Apply test vectors
        for (int i = 0; i < WIDTH; i++) begin
            addr = i;
            en = 1;
            #1;
        end

        addr = {{WIDTH}{1'b1}}; en = 0; #10;
        
        $finish;
    end

endmodule
