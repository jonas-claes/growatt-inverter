# Growatt Inverter

Repository for a structured, multi-session implementation of a Growatt MOD 9000TL3-XH(BP) integration with Loxone.

## Current Focus
- Build a verified Modbus foundation for read and safe write operations.
- Prioritize ShineWiLan-X2 Modbus TCP.
- Keep RS485 as a documented fallback path.

## Working Documents
- [Roadmap](ROADMAP.md)
- [Agent Context](AGENTS.md)
- [Session Checklist](docs/process/SESSION_CHECKLIST.md)
- [Task Template](docs/process/TASK_TEMPLATE.md)

## Workflow Rules
- Work task-by-task using roadmap IDs (example: M2-T01).
- Commit after each completed task.
- Validate behavior before commit, especially for write operations.