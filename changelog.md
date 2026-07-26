# Changelog

All notable project and process changes are tracked in this file.

## 2026-07-25
- Added governance foundation for multi-session execution.
- Added ROADMAP.md, AGENTS.md, and process templates.
- Updated README to point to roadmap and workflow docs.
- Recorded failed TCP baseline result (4/20 successful checks on port 502).
- Added M3-T01b diagnostic runbook and tcp502-stability.ps1 script.
- Logged Wi-Fi diagnostic result: 27/30 success (90%), still blocked for write validation.
- Logged wired LAN diagnostic result: 30/30 success (100%), enabling controlled M3-T02 on wired path.
- Added tcp-read-register.ps1 helper for baseline register reads before write testing.
- Updated M3-T02 runbook with concrete first test target: register 3049 (reversible boolean).
- Added tcp-probe-modbus.ps1 and documented blocker flow for "no working Modbus read combination" outcomes.
- Marked TCP validation as blocked when probe matrix returns no valid read path pending device-side configuration checks.
- Added analysis of official Loxone Growatt template example showing Comm485 (RS485) transport with FC04 registers.
- Clarified that Loxone read success on template 891 does not prove external Modbus TCP access via ShineWiLan-X2.
