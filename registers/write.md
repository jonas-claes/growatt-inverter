# Write Registers (MOD 9000TL3-XH(BP))

Status: Draft
Owner task: M2-T03

## Safety First
- Start with reversible writes only.
- Never perform write tests without a rollback step.
- Every write test must include readback verification.

## Candidate Write Registers
| Function | Register | FC | Type | Allowed Values | Scale | Safety Class | Firmware | Source | Status | Notes |
|---|---:|---|---|---|---|---|---|---|---|---|
| Allow Grid Charge (AcChargeEnable) | 3049 | 06 | U16 | 0/1 | 1 | Low | TBD | SRC-006,SRC-007 | Candidate (Priority 1) | First recommended reversible FC06 test on wired path. Readback on same register. |
| VPP Control Authority | 30100 | 06 | U16 | 0/1 | 1 | Medium | TBD | SRC-007,SRC-008 | Candidate (Priority 2) | May be prerequisite for advanced control paths; firmware dependent behavior expected. |
| Remote Power Control Enable | 30407 | 06 | U16 | 0/1 | 1 | Medium | TBD | SRC-007,SRC-008 | Candidate (Priority 3) | Test only after neutral control values are confirmed on related registers. |
| Force Charge | TBD | 06/16 | U16/U32 | TBD | TBD | Medium | TBD | TBD | Candidate | |
| Force Discharge | TBD | 06/16 | U16/U32 | TBD | TBD | Medium | TBD | TBD | Candidate | |
| Charge Limit | TBD | 06/16 | U16 | TBD | TBD | High | TBD | TBD | Candidate | |
| Discharge Limit | TBD | 06/16 | U16 | TBD | TBD | High | TBD | TBD | Candidate | |
| Grid Charge (legacy/unknown mapping) | TBD | 06/16 | U16 | 0/1 | 1 | Medium | TBD | TBD | Candidate | Keep as placeholder until validated against 3049 mapping. |
| Export Limit | TBD | 06/16 | U16 | TBD | TBD | High | TBD | TBD | Candidate | |

## Verified Write Registers
| Function | Register | FC | Type | Allowed Values | Scale | Firmware | Precondition | Readback Register | Test Evidence |
|---|---:|---|---|---|---|---|---|---|---|

## Test Protocol
1. Capture baseline values for all affected related registers.
2. Apply write with minimal-impact value.
3. Confirm protocol response and readback value.
4. Confirm observed behavior matches expected outcome.
5. Revert change and verify return to baseline.

## Stop Conditions
- If write succeeds but readback differs from expected mapping, stop and mark as blocked.
- If behavior impact is unclear, stop and require controlled retest window.
