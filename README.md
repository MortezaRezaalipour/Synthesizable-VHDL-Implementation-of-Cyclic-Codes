# FPGA-Based Cyclic Code Communication System

## 1. Serial Receiver - Encoder - Serial Transmitter

### Objective
To encode a message for error correction.

### Process
- **Generate a message bitstream** on a computer, simulating the original data to be sent.
- **Transmit the bitstream serially** to the FPGA's first circuit.
- **Encode the bitstream** within the FPGA using a cyclic code encoder. This step introduces redundancy into the message, allowing for error detection and correction at the receiver.
- **Transmit the encoded bitstream** back to the computer, simulating the sending of encoded data over a communication channel.

## 2. Serial Receiver - Decoder - Serial Transmitter

### Objective
To decode the encoded message and correct any errors.

### Process
- **Receive the encoded bitstream** on the second circuit of the FPGA, simulating the reception of transmitted data.
- **Decode the bitstream** using the cyclic code decoder. This step involves checking for errors and correcting them to recover the original message.
- **Transmit the corrected bitstream** back to the computer, demonstrating the recovery of the original message despite the presence of errors.


--- 

# Module Description

## FIFO Receiver Module Overview

### Entity Definition
- **Generic Parameters**:
  - `Byte`: The number of bits in a byte, set to 8 by default.
  - `Bit_Time`: The duration for each bit, set to 5460 by default.
  - `FIFO_Length`: The length of the FIFO buffer, set to 1 by default.
- **Ports**:
  - `Clock`: Input clock signal (STD_LOGIC).
  - `Reset`: Asynchronous reset signal (STD_LOGIC).
  - `RxD`: Received serial data input (STD_LOGIC).
  - `Data`: Parallel data output (STD_LOGIC_VECTOR).
  - `Data_Valid`: Output signal indicating valid data (STD_LOGIC).

### Architecture (Behavioral)
- Implements a state machine with states: `Pre_Idle`, `Idle`, `Receive`, `Store_in_Queue`, `Continue_Stop`, `Output`.
- Manages data reception and assembly from serial to parallel format.

#### State Machine Logic
- **Pre_Idle**: Initializes the receiver and prepares it to receive data.
- **Idle**: Waits for the start bit of incoming data.
- **Receive**: Captures the serial data bit by bit into `RxD_Buffer`.
- **Store_in_Queue**: Transfers the received byte into the FIFO queue.
- **Continue_Stop**: Handles the end of data byte reception.
- **Output**: Assembles the full data word from the FIFO queue and sets it to output.

#### Process Flow
- Operates with a clock-driven process, transitioning between states based on incoming data and internal counters (`Time_counter`, `Bit_Counter`).
- Uses `RxD_Buffer` to accumulate the bits of a single byte.
- Assembles bytes into a 32-bit word in `Data_Reg` and outputs it once fully received.

### Functionality
- `FIFOReceiver` is designed to interface with a serial data source, capturing and converting serial data into a 32-bit parallel output.
- The FIFO queue mechanism allows for buffering bytes to handle variable data rates and ensure data integrity.

---

## FIFOTransmitter VHDL Code Overview

This VHDL code defines a module named `FIFOTransmitter`, which is part of the Serial Receiver - Encoder - Serial Transmitter circuit. It's designed to manage the transmission of data in a serial communication setup.


### Entity Definition
- **Generic Parameters**:

The `FIFOTransmitter` entity is defined with the following generic parameters that allow customization of its behavior:

- `FIFO_Length`: Specifies the length of the FIFO queue used to store the data bytes before transmission. The range is from 1 to 4, allowing for a variable depth of the queue to accommodate different buffering requirements. This flexibility helps in managing data flow, especially in systems with varying latency or speed requirements.

- `Byte`: Defines the size of the data units (in bits) that the transmitter will handle, typically set to 8 to represent a byte. This parameter is crucial for determining how the 32-bit input data is segmented into smaller units for serial transmission.

- `Bit_Time`: Represents the number of clock cycles allocated for transmitting each bit. This is essential for defining the baud rate of the transmission, i.e., the speed at which data is transmitted over the serial link. Adjusting this parameter allows the module to be tailored to different communication speeds, ensuring compatibility with various serial communication standards.

These generic parameters make the `FIFOTransmitter` highly configurable, enabling it to be adapted to a wide range of applications and communication requirements in serial data transmission.

- **Ports**:
  - `Clock`: Input clock signal.
  - `Reset`: Asynchronous reset signal.
  - `Data`: 32-bit input data signal.
  - `Send`: Control signal to start transmission.
  - `TxD`: Serial output data.
  - `TxD_Valid`: Indicates when `TxD` is valid.

### Architecture: Behavioral
- **State Machine** with states:
  - `Idle`
  - `Store_in_Queue`
  - `Set_Data`
  - `Transmit`
  - `Continue_Stop`
- **Process Logic**:
  - Operates on the rising edge of the `Clock`.
  - Includes a reset condition that initializes all signals and sets the machine state to `Idle`.
  - Transitions between states based on the control signals and internal counters.

#### State Descriptions
- `Idle`: Awaits a trigger (`Send` signal) to start data processing.
- `Store_in_Queue`: Breaks down the incoming 32-bit data into 8-bit chunks and queues them.
- `Set_Data`: Prepares a byte from the queue for transmission.
- `Transmit`: Handles the serial transmission of each bit in the data byte, including framing bits (start and stop bits).
- `Continue_Stop`: Manages the end of byte transmission and sets up for the next byte or returns to `Idle` state.

#### Transmission Logic
- Utilizes counters (`Time_Counter` and `Bit_Counter`) to manage the timing and progression through each bit of the data byte.
- Uses a FIFO queue to store and manage data bytes before transmission.
- Dynamically adjusts based on FIFO length and bit time for flexible data handling.

### Key Components
- **Signals** for internal state (`Current`), data handling (`Data_Reg`, `Data_Queue`, `TxD_Buffer`), and output management (`TxD_Reg`, `TxD_Valid_Reg`).
- **Constants** for communication framing (`Stop_bit`, `Start_bit`).

The `FIFOTransmitter` module plays a crucial role in encoding and serially transmitting data, employing a methodical state-driven process to ensure reliable data flow and communication integrity.

--- 

## Encoder Module Overview

### Entity Definition
- **Generic Parameters**:
  - `K`: The number of bits for the message, with a default value of 4, adjustable up to 10.
  - `N`: The number of bits for the codeword, with a default value of 7, adjustable up to 20.
- **Ports**:
  - `Data_in`: Input data bit (STD_LOGIC).
  - `Data_out`: Output encoded bit (STD_LOGIC).
  - `Clk`: Clock signal (STD_LOGIC).
  - `Rst`: Reset signal (STD_LOGIC).
  - `Valid_in`: Signal indicating when the input data is valid (STD_LOGIC).
  - `Valid_out`: Signal indicating when the output data is valid (STD_LOGIC).

### Architecture (Behavioral)
- Utilizes a generator polynomial `GP` (standard for cyclic codes) to define the encoding behavior.
- Contains flip-flops (`Q`) and signals (`D`, `GTemp`, `UQX`) for processing the encoding logic.
- Implements a state machine with two states (`Sw`: `Message` and `Parity`) to handle different phases of the encoding process.

#### Main Logic
1. **FF's Input and XORs**: Generates internal signals (`D`) through conditional XOR operations based on `GP` and the previous state of `Q`.
2. **FF's Outputs Handling**: Manages the update of internal flip-flop states.
3. **Gate Logic**: Decides the temporary gating signal (`GTemp`) based on current operation mode.
4. **Output Management**: Switches the output data between input data and internal state (`Q`) based on the current phase of encoding.

#### Process (Clock-Driven)
- On each rising edge of `Clk`, checks and acts according to the `Rst` signal, updates `Q` and other internal signals based on current inputs and encoding state.
- Manages the `ClockCounter` to transition between message and parity bits handling, thereby progressing through the encoding cycle.

### Functionality
- The `Encoder` is designed to cyclically encode a stream of input bits into a codeword using a specified generator polynomial, adhering to cyclic coding theory.
- It operates serially, processing one bit per clock cycle, and transitions between handling message data and generating parity bits for error detection/correction.


## Encode Module Overview

### Entity Definition
- **Generic Parameters**:
  - `K`: Number of bits in the message, defaulting to 4, with a range up to 10.
  - `N`: Number of bits in the codeword, defaulting to 7, with a range up to 20.
- **Ports**:
  - `Clock`: Input clock signal (STD_LOGIC).
  - `ReSeT`: Asynchronous reset signal (STD_LOGIC).
  - `Val_in`: Input validation signal (STD_LOGIC).
  - `Val_out`: Output validation signal (STD_LOGIC).
  - `U`: Input message vector (STD_LOGIC_VECTOR).
  - `V`: Output codeword vector (STD_LOGIC_VECTOR).

### Architecture (Behavioral)
- Instantiates the `Encoder` component to perform the actual encoding of data.
- Manages the parallel-to-serial and serial-to-parallel data conversion.

#### Main Components
- **Encoder**: A component defined earlier that performs cyclic encoding.
- **Signals**:
  - `Utemp`, `Vtemp`: Temporary vectors for handling input message and output codeword.
  - `Val_in_Reg`, `Val_out_Wire`: Intermediate signals for handling input and output validity.
  - `Serial_U_in`, `Serial_V_out`: Serial signals connected to the encoder for processing each bit.
  - `i`, `j`: Counters for indexing through the message and codeword bits.

#### Process Logic
- Controlled by the `Clock` signal, handling the state and data flow within the module.
- On reset, all signals and counters are reinitialized.
- Sequentially shifts bits from the input message `U` into the encoder, storing encoded bits in `Vtemp`.
- Manages the `Val_out` signal based on the encoder’s output and progression through the codeword.

### Functionality
- The `Encode` module serves as the integration layer between the system's parallel data interface and the serial processing logic of the encoder.
- It translates parallel input data into a serial stream for encoding and converts the encoded serial data back into a parallel format for output.

--- 

# Decoder Module Overview

## Entity Definition
- **Generic Parameters**:
  - `K`: Number of message bits (default is 4, range 0 to 31).
  - `N`: Number of codeword bits (default is 7, range 0 to 31).
- **Ports**:
  - `clock`: Input clock signal.
  - `reset`: Asynchronous reset signal.
  - `Valid_in`: Input signal indicating valid incoming data.
  - `Valid_out`: Output signal indicating valid decoded data.
  - `Data_in`: Input encoded data bit.
  - `Data_out`: Output decoded data bit.
  - `Error_Happened`: Input signal indicating error detection.
  - `Syndrome`: Output vector representing the error syndrome.

## Architecture (Behavioral)
- Uses a generator polynomial `GP` to perform syndrome calculation for error detection and correction.
- Employs shift registers `D_Syndrome`, `Q_Syndrome`, `D_Buffer`, and `Q_Buffer` for processing the data and syndrome.

### Main Logic
1. **Syndrome Calculation**: Dynamically generates the syndrome based on the incoming data and error occurrence.
2. **Buffer Management**: Shifts incoming data through buffer registers to align with decoding process.
3. **Error Detection and Correction Logic**: Utilizes the syndrome to detect and correct errors in the incoming data stream.

### Process Flow
- Controlled by the clock signal, the process block handles data and syndrome register updates, error detection, and data output preparation.
- On reset, all internal signals and counters are reinitialized.
- Processes data bit-by-bit, updating the output based on the calculated syndrome and maintaining counters to manage the decoding cycle.

## Functionality
- The `Decoder` decodes serially received encoded data, checking and correcting errors based on the generator polynomial and syndrome analysis.
- It outputs corrected data bits serially, with `Valid_out` indicating the availability of valid decoded data.


## ErrorPattern_DetectionCircuit Module Overview

### Entity Definition
- **Generic Parameters**:
  - `K`: Number of message bits, with a default of 4 and a range up to 31.
  - `N`: Number of codeword bits, with a default of 7 and a range up to 31.
- **Ports**:
  - `SyndromeVector`: Input syndrome vector, size dependent on `N` and `K`.
  - `Error`: Output signal indicating detection of an error pattern.

### Architecture (Behavioral)
- Simple logic to detect specific error patterns based on the syndrome vector.

#### Logic Description
- The circuit outputs an `Error` signal when a specific pattern is detected in the `SyndromeVector`.
  For example, an error is detected if the first bit is `1`, the second bit is `0`, and the third bit is `1`.

### Functionality
- This circuit is designed to analyze the syndrome vector resulting from the decoding process to detect known error patterns.
- The output `Error` signal can be used to trigger further actions in the decoding process, such as error correction or retransmission request.



# Decode Module Overview

## Entity Definition
- **Generic Parameters**:
  - `K`: The number of message bits, defaulting to 4 with a range up to 31.
  - `N`: The number of codeword bits, defaulting to 7 with a range up to 31.
- **Ports**:
  - `Clock`: System clock input.
  - `Reset`: System reset input.
  - `Input_Ready`: Signal indicating input data is ready.
  - `Output_Ready`: Signal indicating output data is ready.
  - `V`: Input codeword vector.
  - `U`: Output message vector.

## Architecture (Behavioral)
- Implements state machine logic for managing decoding process.
- Instantiates the `Decoder` and `ErrorPattern_DetectionCircuit` components.

### Main Components and Signals
- **`Decoder`**: Component that performs the actual decoding.
- **`ErrorPattern_DetectionCircuit`**: Component for detecting and identifying error patterns in the received codeword.
- **`U_Reg`, `V_Reg`**: Buffers for input and output data handling.
- **State Machine**: Handles different stages of the decoding process (`Idle`, `Busy_Decoding`, `Output`, `Preparing`).

### Process Flow
- Controlled by the system clock, with specific actions triggered on the rising edge.
- Uses a state machine approach to manage the entire decoding process, transitioning between states based on control signals and internal logic.
- During the `Busy_Decoding` state, the module feeds data into the `Decoder` component serially and collects the decoded output.

## Functionality
- `Decode` acts as a wrapper for the `Decoder`, managing data flow and coordinating the decoding process, including error detection and correction.
- It synchronizes the serial data stream with the system’s parallel data handling, providing a fully integrated decoding solution in the communication system.

