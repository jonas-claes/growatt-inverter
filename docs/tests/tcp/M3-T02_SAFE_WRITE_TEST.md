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
