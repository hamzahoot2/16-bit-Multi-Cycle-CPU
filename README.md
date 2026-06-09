# 16-bit Multi-Cycle Harvard RISC Processor

A VHDL implementation of a 16-bit multi-cycle RISC processor using the Harvard architecture (separate instruction memory ITCM and data memory DTCM). The design uses a single central bus to route data efficiently between components, keeping the hardware footprint small.

##  Core Components

* **Central 16-bit Bus:** The single data highway connecting all internal blocks.
* **ALU:** Handles arithmetic/logic operations and outputs the `C`, `Z`, `N`, and `V` status flags.
* **OPC Decoder:** Strips the 4-bit opcode (`IR[15:12]`) to drive the Control Unit.
* **Register File (RF):** Internal register storage for active operands.
* **Staging Registers:** `PC`, `IR`, `Reg_A`, `Reg_C`, and `ADDR_Reg` to hold data between execution clock cycles.
* **Memories (Harvard Architecture):** Separate `ITCM` for instruction code and `DTCM` for data storage.
* **Control Unit (FSM):** The multi-cycle state machine routing the control signals.

## 📐 Hardware Diagrams

### 1. Quartus RTL View
The top-level block diagram from Intel Quartus showing the system abstractions and connections:

![Quartus RTL Viewer](top.jpg)

### 2. DataPath Architecture
The structural layout of the processor:

![DataPath Schematic](DataPath.jpg)

### 3. FSM State Diagram
The multi-cycle state transitions of the Control Unit:

![FSM State Diagram](FSM.png)

## 🗂️ Instruction Set Summary

| Mnemonic | Opcode | Description |
| :--- | :---: | :--- |
| **ADD** | `0000` | Add registers |
| **SUB** | `0001` | Subtract registers |
| **AND** | `0010` | Bitwise AND |
| **OR** | `0011` | Bitwise OR |
| **XOR** | `0100` | Bitwise XOR |
| **JMP** | `0111` | Unconditional jump |
| **JC** | `1000` | Jump if Carry flag is set |
| **JNC** | `1001` | Jump if Carry flag is cleared |
| **MOV** | `1100` | Move immediate configuration data |
| **LD** | `1101` | Load data word from DTCM |
| **ST** | `1110` | Store data word to DTCM |
| **DONE**| `1111` | Terminate processing execution loop |
