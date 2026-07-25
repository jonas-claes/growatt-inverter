# AGENTS

## Purpose
This file defines persistent operating context for contributors and coding agents across sessions.

## Project Context
- Project: Growatt MOD 9000TL3-XH(BP) integration for Loxone.
- Primary path: ShineWiLan-X2 via Modbus TCP.
- Fallback path: RS485 when TCP write capability is blocked or unstable.

## Session Bootstrap (Required)
1. Read ROADMAP.md and identify the next unchecked task.
2. Confirm task scope and acceptance criteria before editing.
3. Keep changes atomic: one task per commit.
4. Validate outcomes and record evidence in docs.
5. Update ROADMAP.md task status and decision log if needed.

## Definition of Done (Per Task)
- Task output exists and is versioned.
- Acceptance criteria are met and briefly verified.
- Relevant docs updated (if behavior or assumptions changed).
- One focused commit created.

## Safety Rules for Write Operations
- Start with reversible commands only.
- Never test write operations without rollback notes.
- Validate write by readback and observed state change.
- Stop and document if results differ from expected behavior.

## Subagent Delegation Patterns

### Research Subagent
Use for source discovery and firmware/register comparison.
Expected output:
- Source list
- Candidate register set
- Confidence notes and unresolved gaps

### Validation Subagent
Use for test matrix and pass/fail evidence design.
Expected output:
- Test cases
- Preconditions
- Expected readback behavior
- Failure handling notes

### Documentation Subagent
Use for end-user guides and troubleshooting structure.
Expected output:
- Draft docs tied to verified behavior only
- Clear assumptions and limitations

## Commit Policy
- Commit after each completed task.
- Preferred format: type(scope): summary
- Include task ID in message, for example: feat(m2-t02): add initial read register table

## Branch Guidance
- For small changes: commit directly on main if agreed.
- For risky or larger work: short-lived branch per milestone/task cluster.

## Notes
If a new session starts without context, this file and ROADMAP.md are the source of truth.
