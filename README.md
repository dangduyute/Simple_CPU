# Simple_CPU

## Introduction

This project demonstrates a **Simple CPU** featuring a lightweight **16-bit Integer ALU**.  
The CPU executes arithmetic and logic operations based on opcodes received via UART.  
It is implemented on an FPGA platform and is controlled directly from a main C program.

> **Note:**  
> This CPU architecture is essentially equivalent to a **Processing Element (PE)** in a **Coarse-Grained Reconfigurable Architecture (CGRA)**.  
> It does **not** follow any standard CPU architecture such as RISC-V, ARM, or MIPS.

---

## ALU Specifications

The ALU operates on **signed 16-bit integers (two’s complement)** and supports the following operations:

The Tiny CPU uses a simple opcode-based protocol to trigger ALU operations:

| Opcode | Mnemonic | Operation       | Description                       |
|--------|----------|-----------------|-----------------------------------|
| **0**  | **NOP**  | —               | No operation                      |
| **1**  | **ADD**  | a + b           | Signed 16-bit integer addition    |
| **2**  | **SUB**  | a − b           | Signed 16-bit integer subtraction |
| **3**  | **MUL**  | a × b           | Signed 16-bit integer multiplication (lower 16 bits) |
| **4**  | **AND**  | a AND b         | Bitwise AND                       |
| **5**  | **OR**   | a OR b          | Bitwise OR                        |
| **6**  | **NOT**  | NOT a           | Bitwise NOT (unary, ignores b)    |
| **7**  | **XOR**  | a XOR b         | Bitwise XOR                       |

- All operations are performed on **16-bit signed integers**.
- Overflow behavior follows standard **two’s complement wrap-around** (as in typical hardware ALUs).
- Opcodes above can be extended for branching, memory access, or custom instructions if needed.

---

## System Overview
1. **Diagram Block.**

   <img src="img/diagram block.png" alt="diagram block" width="500">

2. **Hardware Platform:**  
   Any FPGA board that supports UART communication.

3. **CPU Components:**  
   - 16-bit Integer ALU  
   - 8-bit instruction buffer  
   - 16-bit input/output buffer (a, b, c)  
   - UART RX/TX module  

4. **Software Components:**   
   - C-based main program for user interaction 

5. **Communication Flow:**  

   C ProgramUART → Simple CPU on FPGA → Result sent back via UART → Displayed on Terminal
6. **Video Demo:**
   https://www.youtube.com/watch?v=EzDxxUqb-A4
   
