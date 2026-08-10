# AHB-to-APB Bridge Verification Plan

## 1. Verification Objective

Verify the functional correctness and protocol behavior of the
AHB-to-APB bridge connected to an APB SRAM peripheral.

The verification environment uses SystemVerilog, UVM, functional
coverage, and SystemVerilog Assertions (SVA).

---

## 2. Verification Matrix

| ID | Test | Purpose | Status |
|----|------|---------|--------|
| T01 | write_read_test | Verify basic AHB single WRITE followed by READ | PASS |
| T02 | multi_write_read_test | Verify multiple independent WRITE/READ transactions | PASS |
| T03 | burst_test | Verify INCR burst WRITE/READ transactions | PASS |
| T04 | coverage_test | Verify functional coverage model | PLANNED |
| T05 | sva_test | Verify AHB/APB protocol assertions | PLANNED |
| T06 | wait_state_test | Verify APB wait-state handling using PREADY | PLANNED |
| T07 | error_test | Verify APB/AHB error response handling | PLANNED |
| T08 | random_test | Constrained-random transaction verification | LIMITED BY FSE LICENSE |

---

## 3. Basic Transfer Verification

### T01 — write_read_test

Purpose:

- Verify a single AHB WRITE transaction.
- Verify data reaches the APB SRAM.
- Verify a subsequent AHB READ returns the written data.
- Verify scoreboard comparison.

Expected result:

- WRITE completes successfully.
- READ returns expected data.
- UVM_ERROR = 0.
- UVM_FATAL = 0.

Status: PASS

---

## 4. Multiple Transaction Verification

### T02 — multi_write_read_test

Addresses tested:

- 0x08
- 0x0C
- 0x10

Data tested:

- 0xCAFEBABE
- 0x12345678
- 0xDEADBEEF

Expected result:

All three written values must be correctly returned by
their corresponding READ transactions.

Status: PASS

---

## 5. Burst Verification

### T03 — burst_test

Burst type:

- INCR

Addresses:

- 0x20
- 0x24
- 0x28
- 0x2C

Data:

- 0x11111111
- 0x22222222
- 0x33333333
- 0x44444444

Expected result:

All burst WRITE transactions must complete successfully and
all corresponding READ transactions must return the expected data.

Status: PASS

---

## 6. Functional Coverage

### T04 — coverage_test

Coverage model includes:

- READ/WRITE operation coverage
- Burst type coverage
- Address range coverage
- WRITE/READ × BURST cross coverage

Status: PLANNED

Note:

Functional coverage execution is currently affected by the
Questa FSE SystemVerilog verification-license limitation.

---

## 7. SVA Verification

### T05 — sva_test

Assertions cover:

- APB inactive during reset
- PENABLE requires PSEL
- APB SETUP followed by ACCESS
- APB address stability
- APB write-control stability
- APB write-data stability
- APB transfer completion
- AHB request generating APB SETUP
- AHB HREADY behavior
- AHB/APB write-control consistency
- HRESP error behavior

Status: PLANNED

---

## 8. APB Wait-State Verification

### T06 — wait_state_test

Purpose:

Verify that the bridge correctly handles PREADY remaining LOW
for multiple APB ACCESS cycles.

Expected behavior:

AHB request
→ APB SETUP
→ APB ACCESS
→ PREADY = 0
→ remain in ACCESS
→ PREADY = 1
→ complete AHB transfer

Status: PLANNED

---

## 9. Error Response Verification

### T07 — error_test

Purpose:

Verify propagation of APB peripheral errors to the AHB side.

Expected behavior:

APB error
→ bridge detects error
→ appropriate HRESP response

Status: PLANNED

---

## 10. Constrained-Random Verification

### T08 — random_test

Purpose:

Generate randomized:

- AHB addresses
- WRITE/READ operations
- write data
- burst types

Status: LIMITED BY FSE LICENSE

The current Questa FSE environment reports a SystemVerilog
verification-license limitation for features including
randomization and covergroups.

---

## 11. Verification Completion Criteria

The verification environment will be considered complete when:

1. All directed tests pass.
2. No unexpected UVM_ERROR messages are reported.
3. No UVM_FATAL messages are reported.
4. SVA assertions pass for legal transactions.
5. Intentional protocol violations are detected by SVA.
6. Functional coverage is collected where supported.
7. APB wait states are verified.
8. Error handling is verified.
9. A regression script executes the supported test suite.

---

## 12. Current Status

Core directed verification is operational.

Completed:

- Basic WRITE/READ
- Multiple WRITE/READ
- INCR burst WRITE/READ
- UVM driver
- UVM monitor
- UVM scoreboard
- UVM agent
- UVM environment
- Functional coverage infrastructure
- SVA infrastructure
