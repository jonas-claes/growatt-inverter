# M3-T02 Safe Write Test (Wired Path Only)

Task ID: M3-T02
Status: Ready for execution

## Objective
Validate at least one reversible write command over Modbus TCP with readback confirmation on MOD 9000TL3-XH(BP).

## Safety Gate (mandatory)
- Use wired LAN path only.
- Test only reversible boolean command first.
- Prepare rollback value before first write.
- Stop immediately on unexpected behavior.

## Preconditions
- TCP stability already passed on wired path (30/30).
- Inverter firmware and ShineWiLan-X2 firmware recorded in firmware matrix.
- A known candidate register for reversible control is selected (for example Enable Charge or Enable Discharge), but not yet marked Verified.

## Recommended First Register
- Register: 3049 (Allow Grid Charge / AcChargeEnable)
- Type: U16 boolean
- Values: 0 = disabled, 1 = enabled
- Readback: same register 3049
- Reason: single boolean, reversible, and currently strongest candidate for a first FC06 check on MOD TL3 family path.

## PowerShell Script (recommended)
Use script:
- scripts/tcp-safe-write-test.ps1
- scripts/tcp-read-register.ps1 (for baseline read)
- scripts/tcp-probe-modbus.ps1 (to discover working unit/fc/address mode)

Step 1, read baseline value of 3049:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-read-register.ps1 -IpAddress 192.168.1.102 -UnitId 1 -Register 3049
```

Loxone 891 first-attempt read (recommended):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-read-register.ps1 -IpAddress 192.168.1.102 -UnitId 1 -FunctionCode 4 -Register 35 -ZeroBasedAddress
```

If this read fails, probe combinations automatically:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-probe-modbus.ps1 -IpAddress 192.168.1.102
```

Then retry read with the discovered combination, for example:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-read-register.ps1 -IpAddress 192.168.1.102 -UnitId 0 -FunctionCode 4 -Register 3049 -ZeroBasedAddress
```

If probe shows no working combination:

1. Treat TCP write/read as blocked by device-side config or firmware policy.
2. Verify ShineWiLan-X2 settings in installer-level UI where available:
- Third-party / Modbus TCP single-device control enabled.
- Correct device binding to inverter.
- Address mode and logger address values as expected by your firmware variant.
3. Power-cycle order:
- Restart logger first.
- Restart inverter second.
4. Re-run probe with broader matrix:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-probe-modbus.ps1 -IpAddress 192.168.1.102 -UnitIds 0,1,2,10,11,255 -FunctionCodes 3,4 -Registers 0,1,3000,3049
```

5. If still no response, stop TCP write validation and use RS485 as control path.

Step 2, choose test/rollback values:
- If baseline is 0: TestValue=1, RollbackValue=0
- If baseline is 1: TestValue=0, RollbackValue=1

Example (replace register and values with your chosen reversible test):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp-safe-write-test.ps1 \
	-IpAddress 192.168.1.102 \
	-UnitId 1 \
	-WriteRegister 3049 \
	-ReadbackRegister 3049 \
	-TestValue <FROM_STEP_2> \
	-RollbackValue <FROM_STEP_2> \
	-ConfirmWrite
```

If readback register does not mirror exact test value immediately, add:

```powershell
-SkipAfterWriteMatch
```

## Test Pattern
1. Capture baseline
- Candidate write register address and expected value.
- Related readback register and current state.

2. Apply minimal-impact write
- Write value A -> confirm protocol response.
- Read back and confirm state transition.

3. Rollback
- Write original value B.
- Confirm readback returns to baseline.

4. Evidence
- Timestamped command/output trace.
- Readback values before and after.
- Operational observation note.

## Pass Criteria
- Write acknowledged by endpoint.
- Readback reflects intended change.
- Rollback succeeds and baseline restored.

## Fail Criteria
- Write not acknowledged.
- Readback unchanged or contradictory.
- Delayed or unstable behavior cannot be explained.

## Output Updates After Test
- Update docs/process/FIRMWARE_MATRIX.md FC06/FC16 columns.
- Update registers/write.md candidate row notes and status.
- Update ROADMAP.md M3-T02 status.
