# Synchronous FIFO

A configurable synchronous FIFO (First-In-First-Out) buffer implementation in SystemVerilog, based on the design by Pong P. Chu in _FPGA Prototyping by Systemverilog Examples_.

## Features

- **Synchronous operation**: Single clock domain for both read and write operations
- **Configurable depth and width**: Adjustable data width and address width parameters
- **Full/Empty flags**: Provides write-full and read-empty status signals
- **BRAM-based storage**: Uses synchronous dual-port BRAM for data storage

## Architecture

The FIFO consists of three main modules:

- **`fifo.sv`**: Top-level FIFO module that integrates the controller and memory
- **`fifo_ctrl.sv`**: Control logic that manages read/write pointers and generates status flags
- **`bram_sdp.sv`**: Synchronous dual-port BRAM for data storage

## Parameters

- `DATA_WIDTH`: Width of the data bus (default: 8 bits)
- `ADDR_WIDTH`: Address width determining FIFO depth (default: 4, giving 16 entries)

## Interface

### System Signals
- `clk`: System clock
- `rst_n`: Active-low reset

### Write Interface
- `i_we`: Write enable
- `i_wdata`: Write data input
- `o_wfull`: Write full flag (active high)

### Read Interface
- `i_re`: Read enable
- `o_rdata`: Read data output
- `o_rempty`: Read empty flag (active high)

## Simulation

The project includes a simple simulation testbench using Verilator.

### Prerequisites

- Verilator
- GTKWave

### Running Simulation

```bash
cd sim/
make
```

This will:
1. Compile the SystemVerilog code with Verilator
2. Run the testbench

### Viewing Waveforms

```bash
make waves
```

This opens GTKWave with the generated `waves.vcd` file.

### Cleaning

```bash
make clean
```

## File Structure

```
fifo/
├── rtl/                  # RTL source files
│   ├── fifo.sv           # Top-level FIFO module
│   ├── fifo_ctrl.sv      # FIFO control logic
│   └── bram_sdp.sv       # BRAM memory module
└── sim/                  # Simulation files
    ├── Makefile          # Build and run scripts
    ├── tb_fifo.sv        # Testbench
    └── waves.vcd         # Generated waveforms
```

## Usage Example

```systemverilog
fifo #(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(8)  // 256 entries
) my_fifo (
    .clk        (sys_clk),
    .rst_n      (sys_rst_n),
    .i_re       (read_enable),
    .o_rdata    (read_data),
    .o_rempty   (fifo_empty),
    .i_we       (write_enable),
    .i_wdata    (write_data),
    .o_wfull    (fifo_full)
);
```

## License

This project is released under the MIT License.
