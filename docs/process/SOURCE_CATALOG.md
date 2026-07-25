# Source Catalog

Purpose: track protocol and implementation sources with confidence ratings before adding entries to verified register tables.

## Confidence Scale
- High: official vendor source, or community source with repeatable technical evidence.
- Medium: likely useful but incomplete, mirrored, or not model-specific.
- Low: anecdotal or integration discussion only.

## Sources

| ID | URL | Type | Coverage | Confidence | Notes |
|---|---|---|---|---|---|
| SRC-001 | https://en.growatt.com/products/shinewilan-x2 | Official | Product capabilities, firmware context | High | No direct register map |
| SRC-002 | https://en.growatt.com/upload/file/Single_Device_Control_via_Growatt_Modbus_TCP_(ShineWiLan-X2).pdf?raw=Single_Device_Control_via_Growatt_Modbus_TCP_%28ShineWiLan-X2%29.pdf | Official | Modbus TCP single-device control behavior | High | Critical for TCP path assumptions |
| SRC-003 | https://en.growatt.com/upload/file/ShineWiLan-X2_Datasheet_EN_202402.pdf | Official | Datalogger hardware/feature context | Medium | Minimal register detail |
| SRC-004 | https://www.manualslib.com/manual/3530391/Growatt-Shinewilan-X2.html | Manual | Setup and operational behavior | Medium | Mirror source |
| SRC-005 | https://github.com/mwalle/shinelanx-modbus | Community | Protocol and gateway internals | High | Useful for behavior analysis |
| SRC-006 | https://0xaha.github.io/Growatt_ModbusTCP/controls/entity-reference/ | Community | Model/control capability matrix | High | Includes MOD TL3-XH notes |
| SRC-007 | https://0xaha.github.io/Growatt_ModbusTCP/developer/protocol-vpp/ | Community | VPP register family behavior | High | Candidate register family mapping |
| SRC-008 | https://github.com/0xAHA/Growatt_ModbusTCP/issues/63 | Community | Field reports for write behavior | High | Helpful for risk framing |
| SRC-009 | https://github.com/johanmeijer/grott/raw/refs/heads/master/documentatie/registers.md | Community | Register candidates and ranges | High | Reverse-engineered parts, verify locally |
| SRC-010 | https://www.amosplanet.org/wp-content/uploads/2023/06/Growatt-Inverter-Modbus-RTU-Protocol_II-V1_24-English.pdf | Manual | RTU protocol reference (older family) | Medium | Version-family mismatch possible |
| SRC-011 | https://shop.frankensolar.ca/content/documentation/Growatt/AppNote_Growatt_WIT-Modbus-RTU-Protocol-II-V1.39-English-20240416_(frankensolar).pdf | Manual | Newer protocol/app note candidate | Medium | WIT family, applicability to MOD to validate |
| SRC-012 | https://community.home-assistant.io/t/growatt-via-modbus-over-tcp/580882 | Community | Integration anecdotes | Low | Not a truth source |

## Usage Rules
- Never move a register to Verified on source data alone.
- A Verified entry requires source plus observed device behavior.
- If sources disagree, capture both in Notes and prioritize local test evidence.
