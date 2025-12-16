# Simple CPU – RTL Design, Testbench & C Program

This project implements a **Simple CPU core** using **Verilog**, controlled through a **UART interface**, and accompanied by a **host-side C program** for software interaction.  
The design focuses on a **16-bit signed integer ALU**, where operations are selected via **opcode-based commands** sent from software.

A **testbench** is provided to verify the RTL behavior, and the **C program** demonstrates how the CPU can be controlled from a terminal, illustrating a basic **HW/SW co-design flow**.

> **Note**  
> This Simple CPU is a lightweight, computation-oriented design and is conceptually closer to a **Processing Element (PE)** in a CGRA system.  
> It does not implement a standard instruction set architecture such as RISC-V, ARM, or MIPS.

## Opcode Table (UART Command Format)

The Simple CPU executes **one ALU operation per UART command**.  
Each command consists of:
- **Opcode**: selects the ALU operation
- **Operand A**: 16-bit signed integer
- **Operand B**: 16-bit signed integer (ignored for unary operations)

All operands and results use **two’s complement 16-bit signed representation**.  
Arithmetic overflow follows natural wrap-around behavior.

| Opcode | Mnemonic | Operation | Description |
|------:|----------|-----------|-------------|
| 0 | NOP | — | No operation |
| 1 | ADD | `C = A + B` | Signed integer addition |
| 2 | SUB | `C = A - B` | Signed integer subtraction |
| 3 | MUL | `C = A * B` | Signed multiplication (lower 16 bits) |
| 4 | AND | `C = A & B` | Bitwise AND |
| 5 | OR  | `C = A \| B` | Bitwise OR |
| 6 | NOT | `C = ~A` | Bitwise NOT (operand B ignored) |
| 7 | XOR | `C = A ^ B` | Bitwise XOR |

---

## 1. RTL Design

The RTL implementation is written in **Verilog** and organized into modular components.

### 1.1 Top-Level Module
The top-level module integrates:
- UART receiver and transmitter
- Opcode and operand decoding logic
- 16-bit ALU datapath
- Result formatting and UART response logic

It serves as the main control unit that connects the UART command stream to the internal ALU operations.

---

### 1.2 UART Interface
The UART interface enables communication between the host software and the FPGA.

Main functions:
- Receive opcode and operands from the host
- Transmit computation results back to the host
- Provide a simple, low-bandwidth control interface

This interface allows the CPU to be controlled entirely from a terminal-based application.

---

### 1.3 ALU Core
The ALU is the main computational block of the Simple CPU.

Supported features:
- **16-bit signed integer arithmetic**
- Two’s complement representation
- Bitwise and arithmetic operations

Supported operations include:
- ADD, SUB, MUL
- AND, OR, XOR, NOT
- NOP (no operation)

The ALU output is registered and forwarded to the UART transmit logic.

---

### 1.4 Control Logic
The control logic:
- Decodes incoming opcodes
- Selects the corresponding ALU operation
- Coordinates data flow between UART and ALU
- Ensures correct sequencing of receive → compute → transmit

A simple finite state machine (FSM) is used to manage the operation flow.

---

## 2. Testbench (RTL Verification)

The verification environment is designed to validate the correctness of the RTL implementation.

### 2.1 Verification Goals
The testbench is intended to:
- Verify correct decoding of opcodes
- Validate ALU computation results
- Check proper UART data handling
- Ensure stable behavior under multiple operations

---

### 2.2 Testbench Features
- Clock and reset generation
- UART stimulus emulation
- Automated checking of ALU results
- Console messages for pass/fail reporting

The testbench drives opcode and operand sequences similar to real software usage.

---

### 2.3 Test Scenarios
Typical test scenarios include:
- Single ALU operation tests
- Sequential operations with different opcodes
- Edge cases for signed arithmetic
- Verification of bitwise logic functions

Each test compares the RTL output against expected software-calculated results.

---

## 3. Software Control (C Program)

A **C program** is provided to demonstrate how the Simple CPU can be controlled from a host machine.

### 3.1 Purpose
The C program acts as a **host-side controller**, allowing:
- Sending opcodes and operands over UART
- Triggering ALU computations
- Receiving and displaying results in the terminal

This provides a simple and intuitive way to interact with the hardware design.

---

### 3.2 Software Technique
Typical operation flow:
1. Open UART device
2. Send opcode
3. Send operand A
4. Send operand B
5. Receive computation result
6. Display result on terminal

---

## 4. Demo

A demonstration video showing real-time control of the Simple CPU via terminal:

👉 https://www.youtube.com/watch?v=EzDxxUqb-A4

---

## License

This project is licensed under the **MIT License**.  
See the `LICENSE` file for details.
