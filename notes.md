
combinational/comparator/comparator_tb.sv   -> can be improved
sequential/flip_flop/dff_tb                 -> can be simplified
sequential/counter/counter.sv               -> input ud rename
combinational/decoder/decoder.tb            -> output y rename
combinational/arithmetic/alu/alu.sv         -> change operations to more useful ones
combinational/encoder/encoder.tb            -> check if 01010101 type of inputs should be valid(is it necessary to have only one high bit)
                                            -> update README.md
examples/pattern_detector                   -> MOVED
control/sequence_detector/*.sv              -> rename parameter SEQ to PATTERN
cdc/sync_2ff.sv                             -> check tb and waveform. does it actuallt work as intented (current tb is ai)
cdc/pulse_sync                              -> understand how this works and write it yourself (current version is AI) 

interfaces/                                 -> rewrite tx if necessary.
                                            -> rewrite tx_tb rx_tb top_tb
                                            -> delete the ai one