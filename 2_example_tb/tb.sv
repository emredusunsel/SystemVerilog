module tb;

  bit [1:0] mode;
  bit [2:0] cfg;

  bit clk;
  always #20 clk = ~clk;

  // --------------------------------
  // Coverage storage
  // --------------------------------

  bit mode_hit   [0:3];   // 0 -> 3
  bit cfg10_hit  [0:3];   // 0 -> 3
  bit cfg_lsb_hit[0:1];   // 0 -> 1
  bit sum_hit    [0:10];  // 0 -> 10


  // --------------------------------
  // Sample coverage
  // --------------------------------

  always @(posedge clk) begin

    mode_hit[mode]       = 1;
    cfg10_hit[cfg[1:0]]  = 1;
    cfg_lsb_hit[cfg[0]]  = 1;
    sum_hit[mode + cfg]  = 1;

  end


  // --------------------------------
  // Test stimulus
  // --------------------------------

  initial begin

    for (int i = 0; i < 5; i++) begin

      @(negedge clk);

      mode = $random;
      cfg  = $random;

      $display("[%0t] mode=0x%0h cfg=0x%0h",
               $time, mode, cfg);

    end

  end


  // --------------------------------
  // Calculate coverage
  // --------------------------------

  initial begin

    int mode_count;
    int cfg10_count;
    int cfg_lsb_count;
    int sum_count;

    #500;

    mode_count    = 0;
    cfg10_count   = 0;
    cfg_lsb_count = 0;
    sum_count     = 0;


    // mode
    for (int i = 0; i < 4; i++)
      if (mode_hit[i])
        mode_count++;


    // cfg[1:0]
    for (int i = 0; i < 4; i++)
      if (cfg10_hit[i])
        cfg10_count++;


    // cfg[0]
    for (int i = 0; i < 2; i++)
      if (cfg_lsb_hit[i])
        cfg_lsb_count++;


    // mode + cfg
    for (int i = 0; i < 11; i++)
      if (sum_hit[i])
        sum_count++;


    $display("");
    $display("---------- COVERAGE ----------");

    $display("cp_mode    : %0.2f%%",
             100.0 * mode_count / 4);

    $display("cp_cfg_10  : %0.2f%%",
             100.0 * cfg10_count / 4);

    $display("cp_cfg_lsb : %0.2f%%",
             100.0 * cfg_lsb_count / 2);

    $display("cp_sum     : %0.2f%%",
             100.0 * sum_count / 11);

    $display("--------------------------------");

    $finish;

  end

endmodule