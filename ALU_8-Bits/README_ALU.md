# ALU_8-bits

# 8-bit Arithmetic Logic Unit (ALU) — Verilog HDL

A hierarchical 8-bit ALU implemented in Verilog HDL supporting 16 operations across arithmetic, logic, shift and compare classes. Built from gate-level primitives with full ZNCV flag generation and verified using a self-checking testbench with 84 directed test cases.

---

## Table of Contents

- [Features](#features)
- [Block Diagram](#block-diagram)
- [Module Hierarchy](#module-hierarchy)
- [Opcode Table](#opcode-table)
- [Flag Generation](#flag-generation)
- [Design Highlights](#design-highlights)
- [Verification](#verification)
- [Tools Used](#tools-used)
- [How to Simulate](#how-to-simulate)
- [Project Structure](#project-structure)
- [Key Design Decisions](#key-design-decisions)
- [Author](#author)

---

## Features

- **16 operations** across 4 operation classes
- **Full ZNCV flag generation** — Zero, Negative, Carry, Overflow
- **Hierarchical design** — built from gate level primitives up
- **Barrel shifter** built from 2:1 MUX primitives — 3 MUX layers
- **Signed and unsigned comparison** — separate opcodes following RISC-V convention
- **Operand isolation** — low power technique for unused operands
- **Self-checking testbench** — 84 directed test cases, zero failures

---

## Block Diagram

```
         +--------------------------------------------------+
         |                     ALU.v                        |
         |                                                  |
         |  op[3:2]=00   +------------------------+         |
a[7:0] --+-------------->|      alu_addsub.v      |         |
b[7:0] --+-------------->|    ADD/SUB/INC/DEC     |         |
         |               +------------------------+         |
         |                                                  |
         |  op[3:2]=01   +------------------------+         |
         +-------------->|      alu_logic.v       +-------> result[7:0]
         |               |    AND/OR/XOR/NOT      |         |
         |               +------------------------+ ------> zero
         |                                          ------> negative
         |  op[3:2]=10   +------------------------+ ------> carry
         +-------------->|      alu_shift.v       | ------> overflow
         |               |    LSL/LSR/ASR/ROR     |         |
         |               +------------------------+         |
         |                                                  |
         |  op[3:2]=11   +------------------------+         |
         +-------------->|     alu_compare.v      |         |
         |               |  EQ/LT_U/LT_S/GT_U    |         |
         |               +------------------------+         |
         |                                                  |
         |  op[3:2] selects unit                           |
         |  op[1:0] selects operation within unit          |
         +--------------------------------------------------+
```

---

## Module Hierarchy

```
ALU.v                              <- top level
|
+-- alu_addsub.v                   <- arithmetic unit
|   +-- adder_8bit.v
|       +-- adder_4bit.v
|           +-- full_adder.v       <- 1-bit full adder primitive
|
+-- alu_logic.v                    <- logic unit
|
+-- alu_shift.v                    <- shift unit
|   +-- shift_core.v
|       +-- LSL1.v                 <- layer 1: shift by 1
|       +-- LSL2.v                 <- layer 2: shift by 2
|       +-- LSL3.v                 <- layer 3: shift by 4
|           +-- mux_2_1.v         <- 1-bit 2:1 MUX primitive
|
+-- alu_compare.v                  <- compare unit
    +-- alu_addsub.v               <- reuses subtractor internally
```

---

## Opcode Table

| op[3:0] | op[3:2] | op[1:0] | Operation      | Description                         |
|---------|---------|---------|----------------|-------------------------------------|
| 0000    | 00      | 00      | ADD            | A + B                               |
| 0001    | 00      | 01      | SUB            | A - B                               |
| 0010    | 00      | 10      | INC            | A + 1                               |
| 0011    | 00      | 11      | DEC            | A - 1                               |
| 0100    | 01      | 00      | AND            | A & B                               |
| 0101    | 01      | 01      | OR             | A or B                              |
| 0110    | 01      | 10      | XOR            | A ^ B                               |
| 0111    | 01      | 11      | NOT            | ~A  (B ignored — operand isolated)  |
| 1000    | 10      | 00      | LSL            | Logical Shift Left  by b[2:0]       |
| 1001    | 10      | 01      | LSR            | Logical Shift Right by b[2:0]       |
| 1010    | 10      | 10      | ASR            | Arithmetic Shift Right by b[2:0]    |
| 1011    | 10      | 11      | ROR            | Rotate Right by b[2:0]              |
| 1100    | 11      | 00      | EQ             | A == B  result = 0x01 or 0x00       |
| 1101    | 11      | 01      | LT (unsigned)  | A < B unsigned                      |
| 1110    | 11      | 10      | LT (signed)    | A < B signed                        |
| 1111    | 11      | 11      | GT (unsigned)  | A > B unsigned                      |

> **Note:** op[3:2] selects the functional unit. op[1:0] selects the operation within that unit.
> This structured encoding follows the same principle used in real ISAs like RISC-V.

---

## Flag Generation

| Flag     | Symbol | Condition              | Meaningful For   |
|----------|--------|------------------------|------------------|
| Zero     | Z      | result == 8'b0         | All operations   |
| Negative | N      | result[7] == 1         | All operations   |
| Carry    | C      | Unsigned overflow       | Arithmetic only  |
| Overflow | V      | Signed overflow         | Arithmetic only  |

> Logic and shift operations tie carry and overflow to 0.
> Compare operations output result as 8'h01 (true) or 8'h00 (false).

---

## Design Highlights

### Arithmetic Unit — One Adder for Four Operations

```
All four operations use a single adder_8bit instance.
Control signals b_eff and cin are derived from opcode:

op    Operation    b_eff       cin
00    ADD          B           0      ->  A + B
01    SUB          ~B          1      ->  A + ~B + 1 = A - B
10    INC          8'h00       1      ->  A + 0 + 1  = A + 1
11    DEC          8'hFF       0      ->  A + 0xFF   = A - 1
```

### Arithmetic Unit — Overflow Detection

```
Signed overflow occurs when two same-sign inputs
produce an opposite-sign result:

overflow = (a[7] == b_eff[7]) && (result[7] != a[7])
```

### Logic Unit — Operand Isolation

```
NOT operation uses only operand A — B is unused.
B is forced to 0 when op = NOT to prevent unnecessary
signal switching. This reduces dynamic power consumption.

b_eff = (op[1:0] == 2'b11) ? 8'h00 : b
```

### Shift Unit — Barrel Shifter from MUX Primitives

```
Built as three MUX layers — not using Verilog << operator:

Layer 1 (8 MUXes) — sel=b[0] — shifts by 1 or passes through
Layer 2 (8 MUXes) — sel=b[1] — shifts by 2 or passes through
Layer 3 (8 MUXes) — sel=b[2] — shifts by 4 or passes through

Any shift amount 0-7 achieved by combining layers.
Example: shift by 5 = Layer1(shift 1) + Layer3(shift 4)

Operation    Input to core    Fill value    Output
LSL          a                0             direct
LSR          reverse(a)       0             reverse(result)
ASR          reverse(a)       a[7]          reverse(result)
ROR          reverse(a)       0             reverse(result) | LSL(a, 8-N)

LSR, ASR and ROR reuse the LSL core with input/output
bit reversal — no duplicate hardware.
```

### Compare Unit — Flag Based Comparison

```
Internally instantiates alu_addsub with op=SUB fixed.
Reads subtraction flags to determine comparison result:

EQ      ->  sub_zero
LT_U    ->  ~sub_carry         (carry=0 means borrow = A<B unsigned)
LT_S    ->  sub_negative ^ sub_overflow
GT_U    ->  sub_carry & ~sub_zero

Result encoding: 8'h01 = true,  8'h00 = false
```

### Compare Unit — Signed vs Unsigned (Key Test)

```
a = 200, b = 100

LT_U (op=1101): 200 > 100 unsigned  ->  result = 0x00 (false)
LT_S (op=1110): -56 < +100 signed   ->  result = 0x01 (true)

Same inputs, different opcodes, different results.
This is why separate opcodes matter — follows RISC-V
SLT (signed) and SLTU (unsigned) convention.
```

---

## Verification

```
=====================================
   ALU TESTBENCH - 16 OPERATIONS
   8-bit ALU Verification
=====================================
PASS [Test  1] op=0000 a=5   b=3   | result=8
PASS [Test  2] op=0000 a=100 b=200 | result=44
...
PASS [Test 84] op=1111 a=200 b=100 | result=1
=====================================
TOTAL : 84 tests
PASSED: 84
FAILED: 0
=====================================
```

### Test Coverage

| Module       | Tests  | Operations Covered           |
|--------------|--------|------------------------------|
| alu_addsub   | 15     | ADD, SUB, INC, DEC           |
| alu_logic    | 21     | AND, OR, XOR, NOT            |
| alu_shift    | 29     | LSL, LSR, ASR, ROR           |
| alu_compare  | 20     | EQ, LT_U, LT_S, GT_U        |
| **Total**    | **84** | **All 16 operations**        |

### Flag Coverage

| Flag     | Arithmetic | Logic  | Shift  | Compare |
|----------|-----------|--------|--------|---------|
| Zero     | Yes       | Yes    | Yes    | Yes     |
| Negative | Yes       | Yes    | Yes    | N/A     |
| Carry    | Yes       | tied 0 | tied 0 | tied 0  |
| Overflow | Yes       | tied 0 | tied 0 | tied 0  |

### Testbench Features

- Self-checking — automatic pass/fail per test
- === operator used for exact 4-state comparison
- Pass/fail counter with final summary
- All 4 flags checked on every test
- Edge cases covered — zero, max values, overflow boundaries

---

## Simulation Results

### Arithmetic Waveform
![Arithmetic Operations](sim/arithmetic_wave.png)

### Logic Waveform
![Logic Operations](sim/logic_wave.png)

### Shift Waveform
![Shift Operations](sim/shift_wave.png)

### Compare Waveform
![Compare Operations](sim/compare_wave.png)

---

## Tools Used

| Tool                     | Purpose                 |
|--------------------------|-------------------------|
| Verilog (IEEE 1364-2001) | Hardware description    |
| Xilinx Vivado WebPACK    | Simulation              |
| Behavioral Simulation    | Functional verification |

---

## How to Simulate

### Vivado

```
1. Open Vivado -> Create New Project
2. Add all files from rtl/ as Design Sources
3. Add ALU_test.v from tb/ as Simulation Source
4. Set ALU_test as Simulation Top Module
5. Flow -> Run Simulation -> Run Behavioral Simulation
6. In TCL console type: run all
7. View waveforms and console output
```

### Expected Console Output

```
ALU TESTBENCH - 16 OPERATIONS
8-bit ALU Verification
PASS [Test 1] op=0000 a=5 b=3 | result=8
...
TOTAL : 84 tests
PASSED: 84
FAILED: 0
```

---

## Project Structure

```
ALU_8-bits/
|
+-- rtl/                        <- RTL design files
|   +-- ALU.v                   <- top level module
|   +-- alu_addsub.v            <- ADD, SUB, INC, DEC
|   +-- alu_logic.v             <- AND, OR, XOR, NOT
|   +-- alu_shift.v             <- LSL, LSR, ASR, ROR
|   +-- alu_compare.v           <- EQ, LT_U, LT_S, GT_U
|   +-- adder_8bit.v            <- 8-bit ripple carry adder
|   +-- adder_4bit.v            <- 4-bit ripple carry adder
|   +-- full_adder.v            <- 1-bit full adder primitive
|   +-- shift_core.v            <- unified barrel shift engine
|   +-- LSL1.v                  <- MUX layer: shift by 1
|   +-- LSL2.v                  <- MUX layer: shift by 2
|   +-- LSL3.v                  <- MUX layer: shift by 4
|   +-- mux_2_1.v               <- 1-bit 2:1 MUX primitive
|
+-- tb/                         <- testbench
|   +-- ALU_test.v              <- self-checking testbench
|
+-- sim/                        <- simulation results
|   +-- arithmetic_wave.png
|   +-- logic_wave.png
|   +-- shift_wave.png
|   +-- compare_wave.png
|
+-- README.md
```

---

## Key Design Decisions

**Why build adder from full_adder primitives?**

Demonstrates gate-level understanding of how ripple carry addition works.
Carry propagates from bit 0 through bit 7. Two 4-bit adders are chained
to form the 8-bit adder — shows hierarchical design thinking.

**Why one adder handles ADD, SUB, INC, DEC?**

SUB uses two's complement of B — invert B and set cin=1.
INC forces B to 0 and sets cin=1.
DEC forces B to 0xFF and sets cin=0.
Single adder instance handles all four — no duplicate hardware.

**Why barrel shifter from MUX primitives instead of Verilog << operator?**

The << operator produces a one-line implementation but hides the hardware.
Building from 2:1 MUX primitives shows the actual gate-level implementation —
three layers of MUXes each controlled by one bit of the shift amount.
For right shift, input bits are reversed before entering the left-shift core
and reversed again at output — reusing hardware instead of building a
separate right-shifter.

**Why separate opcodes for signed and unsigned comparison?**

Follows RISC-V convention — SLT (Set Less Than signed) and SLTU
(Set Less Than Unsigned) are separate instructions. Avoids an extra
control signal pin on the ALU, keeps the opcode space clean, and
matches real ISA design practice.

**Why structured opcode encoding — op[3:2] as class selector?**

Upper 2 bits select the functional unit, lower 2 bits select the
operation within that unit. Identical to how real ISAs group instructions
by type. Makes the top-level decoder a simple 4-way MUX on op[3:2] —
clean and scalable to more operations.

---

## Author

**Shriya Srivastava**

[GitHub Profile](https://github.com/Shriyasri25)
