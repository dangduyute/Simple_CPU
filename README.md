## 2. Testbench (RTL Verification)

The verification environment is implemented in **SystemVerilog** and follows a **modular, transaction-based testbench architecture**.  
Although it does not rely on UVM, the structure is inspired by common verification components such as driver, monitor, and scoreboard.

---

### 2.1 Testbench Architecture

The testbench is composed of the following main components:

- **Interface**
- **Transaction (Packet)**
- **Driver**
- **Monitor**
- **Scoreboard**
- **Stimulus / Generator**
- **Top-level Testbench**

Each component has a clear responsibility, improving readability, scalability, and debuggability.

---

### 2.2 Interface

The `interface` module encapsulates all DUT signals, including:
- Clock and reset
- UART transmit and receive signals
- Control and data signals related to opcode and operands

Using an interface simplifies signal connections and allows verification components to access DUT signals in a clean and structured way.

---

### 2.3 Transaction (Packet)

The `packet` class defines a **transaction object** that represents one CPU operation.

A packet typically contains:
- Opcode
- Operand A
- Operand B
- Expected result (calculated in software)

This abstraction allows stimulus generation and result checking to be performed at a higher level than raw signal toggling.

---

### 2.4 Driver

The `Driver` component is responsible for:
- Receiving transaction packets from the stimulus
- Driving opcode and operand data to the DUT through the interface
- Emulating UART-based command transmission timing

The driver converts high-level transactions into cycle-accurate signal activity.

---

### 2.5 Monitor

The `Monitor` observes DUT outputs without modifying them.

Its responsibilities include:
- Capturing results produced by the Simple CPU
- Packaging observed outputs into transactions
- Forwarding the collected data to the scoreboard

This passive observation model ensures that verification does not interfere with DUT behavior.

---

### 2.6 Scoreboard

The `Scoreboard` performs **functional verification** by:
- Comparing DUT results against expected results
- Reporting pass/fail status for each operation
- Detecting arithmetic, logic, or protocol mismatches

This component provides automatic result checking and clear debug information when errors occur.

---

### 2.7 Stimulus Generation

The `Stimulus` module generates a sequence of test transactions.

Main behavior:
- For each test iteration, Stimulus creates a `packet` object and calls `randomize()` to generate **random input values**.
- After randomization, the expected value is prepared (via `post_randomize()` inside the packet), so the testbench always has a reference result for checking.

Transactions are sent to the driver using mailbox-based communication.

---

### 2.8 Top-Level Testbench

The `testbench` module:
- Instantiates the DUT
- Connects all verification components
- Starts the stimulus execution
- Controls simulation flow and termination

Simulation logs clearly indicate transaction flow and verification results.

---

### 2.9 Verification Goals

The testbench is designed to:
- Verify correct opcode decoding
- Validate ALU computation accuracy
- Ensure stable UART-based command handling
- Detect functional mismatches early in simulation

This environment provides confidence in RTL correctness before FPGA deployment

4. **Software Components:**   
   - C-based main program for user interaction 

5. **Communication Flow:**  

   C Program → UART → Simple CPU on FPGA → Result sent back via UART → Displayed on Terminal
6. **Video Demo:**
   https://www.youtube.com/watch?v=EzDxxUqb-A4
   
