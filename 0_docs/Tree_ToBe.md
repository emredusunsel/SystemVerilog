rtl/
│
├── combinational/
│   │
│   ├── arithmetic/
│   │   ├── full_adder.sv
│   │   ├── rca.sv
│   │   └── alu.sv                  ** WRITE YOUR OWN TB
│   │
│   ├── mux/
│   │   └── mux.sv
│   │
│   ├── barrel_shifter/
│   │   └── barrel_shifter.sv
│   │
│   ├── comparator/
│   │   └── comparator.sv
│   │
│   ├── decoder/
│   │   └── decoder.sv
│   │
│   └── encoder/
│   |   └── priority_encoder.sv
|   |
|   └── mux/
|       └── mux.sv 
│
├── sequential/
│   │
│   ├── flip_flop/
│   │   └── dff.sv
│   │
│   ├── register/
│   │   └── register.sv
│   │
│   ├── counter/
│   │   └── counter.sv
│   │
│   └── shift_register/
│       └── shift_register.sv
│
├── control/
│   ├── fsm.sv
│   ├── sequence_detector.sv
│   └── arbiter.sv
│
├── edge_detection/
│   └── sync_edge_detector.sv
│
├── cdc/
│   └── sync_2ff.sv
│   └── handshake_sync.sv           ** LATER
|   ├── pulse_sync.sv               ** WRITE
|   └── aysnc_fifo.sv               ** WRITE BUT CHECK FOLDER LOCATION
│
└── memory/
|   ├── fifo.sv                     ** MAYBE ADD asnc_fifo
|   └── single_port_ram.sv          ** MAYBE ADD dual_port_ram
│
└── intefaces/                      ** ADD THESE
    ├── uart.sv
    └── spi.sv
    ├── i2c.sv