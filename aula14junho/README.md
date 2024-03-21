# RISC-V Processor Development in Verilog

This Verilog project involves the creation of a RISC-V processor, integrating data flow and a state machine. The module encompasses various inputs and outputs, including clock, reset, opcode, ALU control signals, memory write enables, and register file write enables. It implements functionality for data and instruction memory access, ALU operations, register file operations, immediate generation, and control signals. Additionally, it employs various modules for components such as ALU, ALU control, register file, multiplexers, and PC.

## Project Components:

- **(UC):**
  - CPU of the RISC-V processor.
  - Manages instruction decoding, control signal generation, and state transitions.
  - Inputs: clock, reset, opcode; Outputs: control signals (memory write enables, register file write enables, ALU control signals, multiplexer selector signals).
  - Integrates a state machine for efficient operation (IDLE, FETCH, DECODE, EXECUTE, WRITE_BACK).
  - Generates control signals based on current state and opcode for instruction processing.

- **Data Flow:**
  - Involves accessing data and instruction memory, ALU operations, and register file management.
  - Instructions fetched from instruction memory; data read from or written to data memory.
  - ALU performs operations (addition, subtraction, logical AND, OR) based on control signals.
  - Register file stores operands and results, controlled by the microcontroller.
  - Immediate values generated for instructions based on opcode and instruction fields.
  - Control signals direct data flow, with multiplexers selecting inputs based on signals.


## Functionality:
- The microcontroller processes instructions fetched from memory and executes them based on the opcode.
- Control signals are generated to enable memory and register file write operations.
- Data and instruction memory access, ALU operations, register file operations, and immediate generation are implemented.
- The project aims to simulate the behavior of a RISC-V processor using Verilog, integrating data flow and a state machine for efficient operation.

