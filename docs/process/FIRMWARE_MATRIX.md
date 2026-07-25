# Firmware Matrix

Purpose: capture the exact firmware context used in tests and map it to observed Modbus behavior.

## Current Target System

| Component | Version | Source | Status | Notes |
|---|---|---|---|---|
| Inverter Model | MOD 9000TL3-XH(BP) | User | Known | Hardware target |
| Inverter Firmware | TBD | Device readout | Unknown | Fill before write tests |
| ShineWiLan-X2 Firmware | TBD | Shine app / logger info | Unknown | Fill before write tests |
| Loxone Config | 17.1.6.30 | User | Known | Confirm still current |
| Transport | Modbus TCP (port 502) | Project decision | Planned | Primary path |

## Behavior Matrix

| Inverter FW | Logger FW | Read Status | Write Status | FC06 | FC16 | Notes |
|---|---|---|---|---|---|---|
| TBD | TBD | Not tested | Not tested | TBD | TBD | Initial baseline |
| TBD | TBD | Unstable TCP socket (4/20 reachability) | Blocked | Blocked | Blocked | 2026-07-25: Test-NetConnection to 192.168.1.102:502 succeeded once, but stability loop passed only 4/20 attempts. Do not start write tests on this path yet. |

## Required Before M3-T02
- Inverter firmware recorded.
- ShineWiLan-X2 firmware recorded.
- At least one stable read polling test completed.
- TCP stability recovered to at least 19/20 successful socket checks in the baseline loop.
