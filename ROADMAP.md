# Growatt-Loxone Roadmap

## Vision
Build a reliable, testable, and documented integration for Growatt MOD 9000TL3-XH(BP) with Loxone, starting with ShineWiLan-X2 Modbus TCP and clear RS485 fallback guidance.

## Scope
- In scope: MOD 9000TL3-XH(BP), Loxone Config 17.x, ShineWiLan-X2 Modbus TCP, validated read and safe write flows.
- Out of scope (initial): Broad multi-model support and full RS485 implementation in v0.1.

## Milestones

### M1 - Governance and Baseline
Status: Completed
Goal: Repository and process setup for multi-session execution.

Tasks:
- [x] M1-T01 Add roadmap, AGENTS, and process templates
- [x] M1-T02 Define commit cadence and task DoD
- [x] M1-T03 Add session startup and shutdown checklist

### M2 - Protocol and Register Foundation
Status: In Progress
Goal: Build a verified register truth-source.

Tasks:
- [x] M2-T00 Create register workbook scaffolding (read/write/changelog)
- [x] M2-T01 Collect official MOD TL3-XH(BP) register sources
- [ ] M2-T02 Build read register table with scaling and units
- [ ] M2-T03 Build write register table with safety notes

### M3 - Connectivity and Write Validation (TCP)
Status: In Progress
Goal: Confirm what works through ShineWiLan-X2 Modbus TCP.

Tasks:
- [x] M3-T01 Verify port 502 connectivity and stability (executed: unstable 4/20)
- [x] M3-T01b Isolate TCP instability causes (network/logger path) - diagnostic package prepared
- [ ] M3-T02 Validate at least one safe write + readback flow (unblocked on wired path)
- [ ] M3-T03 Document decision: TCP writes usable vs RS485 fallback needed

### M4 - Loxone Template v0.1
Status: Planned
Goal: Deliver first practical template mapping.

Tasks:
- [ ] M4-T01 Define datapoint naming and conversion rules
- [ ] M4-T02 Create v0.1 mapping spec (read + core writes)
- [ ] M4-T03 Add test scenarios and expected outcomes

### M5 - Publish and Iterate
Status: Planned
Goal: Public repo quality and release discipline.

Tasks:
- [ ] M5-T01 Improve README with compatibility matrix and quickstart
- [ ] M5-T02 Add troubleshooting and known limitations
- [ ] M5-T03 Tag v0.1 release and changelog entry

## Decision Log
- 2026-07-25: Prioritize ShineWiLan-X2 Modbus TCP first.
- 2026-07-25: Include read plus battery write scope in v0.1.
- 2026-07-25: Keep AGENTS.md as persistent session bootstrap context.
- 2026-07-25: Enforce one-task-one-commit cadence with task IDs.
- 2026-07-25: Introduce register workbook files before source ingestion.
- 2026-07-25: Source catalog added with confidence scoring before register verification.
- 2026-07-25: Connectivity test procedure standardized before any write tests.
- 2026-07-25: Initial TCP baseline failed stability threshold (4/20), write validation blocked pending diagnosis.
- 2026-07-25: Wi-Fi diagnostic improved to 27/30 but still below threshold; wired test required before M3-T02.
- 2026-07-25: Wired LAN diagnostic passed 30/30, so M3-T02 is unblocked on wired path only.

## Risks
- Write registers may be blocked on some ShineWiLan-X2 firmware.
- Register behavior may vary by inverter firmware.
- Unsafe write tests can impact battery operation if not gated.

## Dependencies
- Access to device telemetry and controlled test windows.
- Firmware versions documented before validation.
- Confirmed safety guardrails for write testing.
