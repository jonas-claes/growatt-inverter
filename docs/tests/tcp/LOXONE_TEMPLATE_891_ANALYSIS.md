# Loxone Template 891 Analysis

Date: 2026-07-26
Source file inspected: docs/tests/tcp/Growatt Inverter Example.Loxone

## Key Finding
The official Loxone Growatt example linked from template 891 uses a Modbus Extension object of type Comm485 (RS485), not a TCP client object.

Evidence from XML:
- Comm object: Type="Comm485" with Title="Modbus Extension"
- Serial settings: Baudrate="9600", Databits="8"
- Device object: Type="ModbusDev" Channel="1"
- Sensors use ModbusCmd="4" (FC04)
- Register examples: 35, 53, 55, 40, 44, 48 and status at default/0

## Implication
Successful reads in Loxone using template 891 do not prove that ShineWiLan-X2 Modbus TCP read/write path is open from external clients.

This resolves the apparent contradiction:
- Loxone can read using RS485 Modbus Extension profile.
- External Modbus TCP probe can still fail if TCP single-device control is blocked or restricted on the logger/firmware.

## Practical Next Decision
1. For reliable control path in this project, prioritize RS485 for read/write validation.
2. Keep TCP as optional path requiring explicit logger-side enablement and independent validation.
3. Continue collecting firmware/config evidence for ShineWiLan-X2 TCP behavior, but do not block RS485 progress.
