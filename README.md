# AHB-to-APB Bridge — UVM-Based Verification

A SystemVerilog/UVM verification project for an AMBA AHB-to-APB bridge. The project includes RTL verification, UVM stimulus and checking, functional coverage, SystemVerilog Assertions (SVA), APB wait-state verification, APB error-response verification, and an automated regression flow using Questa.

## Project Overview

The verification environment targets the following goals:

- Verify AHB write/read functionality.
- Verify multiple write/read transactions.
- Verify incrementing burst transfers.
- Verify APB SETUP-to-ACCESS protocol behavior.
- Verify APB wait-state handling.
- Verify APB error-response propagation.
- Detect intentional protocol violations using SVA.
- Measure functional coverage across operation type, burst type, address ranges, and operation/burst combinations.
- Provide a repeatable UVM + SVA regression.

## Architecture

```text
                    AHB MASTER / UVM AGENT
                              |
                              | AHB transaction
                              v
                     +-------------------+
                     |   AHB-APB BRIDGE  |
                     |                   |
                     |   IDLE            |
                     |    |              |
                     |   SETUP           |
                     |    |              |
                     |   ACCESS          |
                     +---------+---------+
                               |
                               | APB transaction
                               v
                     +-------------------+
                     |   APB PERIPHERAL  |
                     |   SRAM CONTROLLER |
                     +---------+---------+
                               |
                               v
                           APB SRAM
```

## Repository Structure

```text
AHB-TO-APB-UVM/
├── rtl/
│   ├── ahb_apb_bridge.sv
│   └── apb_sram_ctrl.sv
├── interface/
│   └── ahb_if.sv
├── transaction/
│   └── ahb_transaction.sv
├── sequence/
│   ├── ahb_base_sequence.sv
│   ├── ahb_write_read_seq.sv
│   ├── ahb_multi_write_read_seq.sv
│   ├── ahb_burst_seq.sv
│   └── ahb_coverage_seq.sv
├── sequencer/
│   └── ahb_sequencer.sv
├── driver/
│   └── ahb_driver.sv
├── monitor/
│   └── ahb_monitor.sv
├── agent/
│   └── ahb_agent.sv
├── scoreboard/
│   └── ahb_scoreboard.sv
├── coverage/
│   └── ahb_coverage.sv
├── env/
│   └── ahb_env.sv
├── test/
│   ├── base_test.sv
│   ├── write_read_test.sv
│   ├── multi_write_read_test.sv
│   ├── burst_test.sv
│   └── coverage_test.sv
├── assertions/
│   ├── ahb_apb_assertions.sv
│   └── tb/
│       ├── sva_violation_tb.sv
│       ├── wait_state_tb.sv
│       └── error_response_tb.sv
├── top/
│   └── tb_top.sv
├── sim/
│   └── regression.sh
├── ahb_uvm_pkg.sv
├── .gitignore
└── README.md
```

## UVM Architecture

```text
                    +----------------------+
                    |        TEST          |
                    +----------+-----------+
                               |
                               v
                    +----------------------+
                    |       UVM ENV        |
                    |                      |
                    |  +---------------+   |
                    |  |   AHB AGENT   |   |
                    |  |               |   |
                    |  | Sequencer     |   |
                    |  |     |         |   |
                    |  |     v         |   |
                    |  | Driver -----> DUT
                    |  |               |   |
                    |  | Monitor <-----|---+
                    |  +-------+-------+   |
                    |          |            |
                    |          v            |
                    |     Scoreboard        |
                    |          |            |
                    |          v            |
                    |       Coverage        |
                    +-----------------------+
```

### Transaction

`ahb_transaction` represents an AHB transfer. It contains fields for:

- `write`
- `addr`
- `wdata`
- `rdata`
- `burst`
- `ready`
- `resp`

### Sequences

Directed sequences generate:

- Basic write/read traffic.
- Multiple write/read traffic.
- INCR burst traffic.
- Coverage-closure traffic.

### Driver

The driver converts `ahb_transaction` objects into pin-level AHB activity.

### Monitor

The monitor observes completed AHB transactions and publishes them through an analysis port.

### Scoreboard

The scoreboard maintains expected values from writes and compares returned read data against those expected values.

### Coverage

The coverage subscriber samples monitored transactions and reports functional coverage at the end of the UVM run.

## Scoreboard / Reference Checking

For a write:

```text
AHB WRITE
   |
   +--> address = 0x08
   +--> data    = 0xCAFEBABE
             |
             v
       expected memory
       [0x08] = CAFEBABE
```

For a subsequent read:

```text
AHB READ
   |
   +--> address = 0x08
             |
             v
       DUT returns CAFEBABE
             |
             v
       Compare with expected
             |
        +----+----+
        |         |
       PASS      FAIL
```

Example successful result:

```text
[SCOREBOARD] READ PASS:
ADDR=00000008 EXPECTED=cafebabe ACTUAL=cafebabe
```

## Functional Coverage

The coverage model tracks:

### Operation type

- READ
- WRITE

### Burst type

- SINGLE
- INCR
- INCR4

### Address ranges

- `0x00 - 0x3F`
- `0x40 - 0x7F`
- `0x80 - 0xBF`
- `0xC0 - 0xFF`

### Cross coverage

The environment tracks:

- READ × SINGLE
- READ × INCR
- READ × INCR4
- WRITE × SINGLE
- WRITE × INCR
- WRITE × INCR4

The dedicated coverage sequence targets previously uncovered combinations and address ranges.

## SystemVerilog Assertions

The SVA checker verifies protocol-level behavior between AHB and APB.

A key checked relationship is:

```text
APB SETUP -> APB ACCESS
```

The intentional violation test produces:

```text
[SVA] APB SETUP was not followed by ACCESS
```

The test is considered successful when this expected assertion violation is detected.

The SVA environment also includes APB error-response checking through `PSLVERR`.

## APB Wait-State Verification

The wait-state test holds `PREADY` low for multiple APB ACCESS cycles.

Expected behavior:

```text
APB SETUP
    |
    v
APB ACCESS
    |
    +---- PREADY=0 ----+
    |                  |
    +------------------+
    |
    | PREADY=1
    v
Transfer complete
```

Observed successful behavior:

```text
PREADY remained LOW for multiple cycles
Bridge remained in ACCESS
HREADY remained LOW during wait states
Transfer completed after PREADY became HIGH
Observed wait cycles = 3
```

The test completed with zero errors and zero warnings.

## APB Error Response

The error-response test verifies propagation of an APB slave error toward the AHB side:

```text
APB PSLVERR
     |
     v
AHB-APB Bridge
     |
     v
AHB HRESP
```

The APB `PSLVERR` signal is connected into the SVA testbench so that error behavior can be checked explicitly.

## Regression Results

The automated regression executes seven tests:

| # | Test | Result |
|---|---|---|
| 1 | Basic Write/Read | PASS |
| 2 | Multiple Write/Read | PASS |
| 3 | INCR Burst | PASS |
| 4 | Coverage Closure | PASS |
| 5 | SVA Violation | PASS |
| 6 | APB Wait State | PASS |
| 7 | APB Error Response | PASS |

### Final result

```text
Total tests     : 7
Tests passed    : 7
Tests failed    : 0

REGRESSION STATUS : PASS
```

The SVA violation test is intentionally expected to trigger an assertion; detecting that violation is the PASS condition.

## Example UVM Output

```text
[AHB_DRIVER] Driving:
WRITE=1 ADDR=00000008 WDATA=cafebabe BURST=000

[AHB_MONITOR] Observed AHB:
WRITE=1 ADDR=00000008 WDATA=cafebabe
RDATA=00000000 BURST=000 RESP=0

[SCOREBOARD] WRITE:
ADDR=00000008 DATA=cafebabe

[SCOREBOARD] READ PASS:
ADDR=00000008 EXPECTED=cafebabe ACTUAL=cafebabe
```

## Simulation Environment

- SystemVerilog
- UVM 1.1d
- Questa Altera Starter FPGA Edition 2025.2
- Linux / WSL
- Git / GitHub

## Running the Regression

From the project root:

```bash
cd ~/majorproj
```

Make the regression script executable if required:

```bash
chmod +x sim/regression.sh
```

Run:

```bash
./sim/regression.sh
```

Syntax-check the script:

```bash
bash -n sim/regression.sh
```

The regression script compiles the UVM environment and SVA testbenches and executes the configured seven-test regression.

## Running Individual UVM Tests

After compilation, select a test with:

```bash
vsim -c work.tb_top   +UVM_TESTNAME=write_read_test   -do "run -all; quit -f"
```

Available UVM tests:

```text
write_read_test
multi_write_read_test
burst_test
coverage_test
```

## SVA Testbenches

The assertion testbenches include:

```text
sva_violation_tb
wait_state_tb
error_response_tb
```

## Verification Feature Status

| Feature | Status |
|---|---|
| AHB write/read | Implemented |
| Multiple transactions | Implemented |
| INCR burst | Implemented |
| UVM driver | Implemented |
| UVM monitor | Implemented |
| UVM scoreboard | Implemented |
| Functional coverage | Implemented |
| Coverage closure sequence | Implemented |
| SVA protocol checking | Implemented |
| Intentional SVA violation test | Implemented |
| APB wait-state verification | Implemented |
| APB error-response verification | Implemented |
| Automated regression | Implemented |
| Seven-test regression | PASS |

## Skills Demonstrated

- SystemVerilog
- UVM sequence/sequencer/driver architecture
- UVM monitors and analysis ports
- Scoreboard-based checking
- Directed verification
- Burst verification
- Functional coverage
- Cross coverage
- Coverage-driven stimulus
- SystemVerilog Assertions
- Protocol violation testing
- APB wait-state modeling
- Error-response verification
- Automated simulation regression
- Git/GitHub workflow

## Future Enhancements

Potential next steps:

- Constrained-random transaction generation
- More complete AHB burst support
- Additional AHB/APB protocol assertions
- Assertion coverage reporting
- Formal verification of bridge properties
- Separate APB agent and monitor
- APB-side scoreboard/reference model
- UVM register abstraction layer (RAL)
- CI-based regression using GitHub Actions

## Author

**Sahil Jangra**

Electronics & Communication Engineering

Project: **AHB-to-APB Bridge — UVM-Based Verification**

Repository: https://github.com/sahil9325/AHB-TO-APB-UVM
