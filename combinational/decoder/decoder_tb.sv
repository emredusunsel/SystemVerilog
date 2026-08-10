`timescale 1ps/1ps

module decoder_tb;

    logic [2:0] addr;
    logic en;
    logic [7:0] y;

    decoder dut(
        .addr(addr),
        .en(en),
        .y(y)
    );

    integer i;

    initial begin
        // Create waveform file
        $dumpfile("wave.vcd");
        $dumpvars(0, decoder_tb);

        // Print values whenever they change
        $monitor("Time=%0t  addr=%d  en=%d  y=%b", $time, addr, en, y);

        // Apply test vectors
        for (i = 0; i < 8; i++) begin
            addr = i;
            en = 1;
            #10;
        end

        addr = 3'd5; en = 0; #10;
        
        $finish;
    end

endmodule
