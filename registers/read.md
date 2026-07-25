# Read Registers (MOD 9000TL3-XH(BP))

Status: Draft
Owner task: M2-T02

## Notes
- This file is the truth-source for read-only telemetry mapping.
- Only verified entries should move from Candidate to Verified.

## Candidate Registers
| Signal | Register | FC | Type | Signed | Scale | Unit | Firmware | Source | Status | Notes |
|---|---:|---|---|---|---|---|---|---|---|---|
| PV1 Voltage | TBD | 03/04 | U16 | No | TBD | V | TBD | TBD | Candidate | |
| PV1 Current | TBD | 03/04 | U16 | No | TBD | A | TBD | TBD | Candidate | |
| PV1 Power | TBD | 03/04 | U16/U32 | No | TBD | W | TBD | TBD | Candidate | |
| PV2 Voltage | TBD | 03/04 | U16 | No | TBD | V | TBD | TBD | Candidate | |
| PV2 Current | TBD | 03/04 | U16 | No | TBD | A | TBD | TBD | Candidate | |
| PV2 Power | TBD | 03/04 | U16/U32 | No | TBD | W | TBD | TBD | Candidate | |
| AC Total Power | TBD | 03/04 | S32/U32 | TBD | TBD | W | TBD | TBD | Candidate | |
| Grid Import/Export | TBD | 03/04 | S32 | Yes | TBD | W | TBD | TBD | Candidate | |
| Battery SOC | TBD | 03/04 | U16 | No | TBD | % | TBD | TBD | Candidate | |
| Battery Voltage | TBD | 03/04 | U16 | No | TBD | V | TBD | TBD | Candidate | |
| Battery Current | TBD | 03/04 | S16/S32 | Yes | TBD | A | TBD | TBD | Candidate | |
| Battery Temperature | TBD | 03/04 | S16 | Yes | TBD | C | TBD | TBD | Candidate | |
| Charge Power | TBD | 03/04 | U16/U32 | No | TBD | W | TBD | TBD | Candidate | |
| Discharge Power | TBD | 03/04 | U16/U32 | No | TBD | W | TBD | TBD | Candidate | |
| Load Power | TBD | 03/04 | U16/U32 | No | TBD | W | TBD | TBD | Candidate | |
| Inverter State | TBD | 03/04 | U16 | No | 1 | enum | TBD | TBD | Candidate | |
| Fault Code | TBD | 03/04 | U16/U32 | No | 1 | code | TBD | TBD | Candidate | |
| Warning Code | TBD | 03/04 | U16/U32 | No | 1 | code | TBD | TBD | Candidate | |

## Verified Registers
Move rows here only after test proof exists.

| Signal | Register | FC | Type | Signed | Scale | Unit | Firmware | Source | Test Evidence |
|---|---:|---|---|---|---|---|---|---|---|

## Verification Rules
- Register address, function code, and scaling must be confirmed by both source and observed value behavior.
- Any mismatch between source and observed value must be logged in notes with date and test context.
