rtl/
│
├── combinational/
│   │
│   ├── arithmetic/
│   │   ├── full_adder.sv
│   │   ├── rca.sv
│   │   └── alu.sv              ** WRITE
│   │
│   ├── mux/
│   │   └── mux.sv
│   │
│   ├── barrel_shifter/             ** HAS 2 VERSIONS. MAKE IT ONE GOOD PARAMETRIC ONE
│   │   └── barrel_shifter.sv
│   │
│   ├── comparator/
│   │   └── comparator.sv           ** MAKE IT PARAMETRIC
│   │
│   ├── decoder/
│   │   └── decoder.sv              ** MAKE PARAMETRIC
│   │
│   └── encoder/
│   |   └── priority_encoder.sv     ** MAKE PARAMETRIC PRIORITY ENCODER
|   |
|   └── mux/                        ** WRITE
|       └── mux.sv 
│
├── sequential/
│   │
│   ├── flip_flop/
│   │   └── dff.sv                  ** MAKE 1 BIT
│   │
│   ├── register/
│   │   └── register.sv             ** DOESNT HAVE TB
│   │
│   ├── counter/
│   │   └── counter.sv              ** ADD UP/DOWN
│   │
│   └── shift_register/
│       └── shift_register.sv
│
├── control/
│   ├── fsm.sv
│   ├── sequence_detector.sv        ** pick between sequence and pattern (parametric by sequence?)
│   └── arbiter.sv                  ** WRITE
│
├── edge_detection/
│   └── sync_edge_detector.sv
│
├── cdc/                            ** WRITE
│   └── synchronizer.sv
│   └── handshake_sync.sv           ** LATER
│
└── memory/
    ├── fifo.sv                     ** MAYBE ADD asnc_fifo
    └── single_port_ram.sv          ** MAYBE ADD dual_port_ram