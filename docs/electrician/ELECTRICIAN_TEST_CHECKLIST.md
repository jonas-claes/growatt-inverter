# Electrician Test Checklist

Scope: test-only, no modification of existing production project.

## Preconditions
- Use separate test project/session in Loxone Config.
- Keep production project closed or read-only.
- Logger reachable on network.

## TCP test settings to try
- Protocol: Modbus TCP
- Target IP: inverter/logger IP
- Port: 502
- Unit ID order: 1, then 0, then 2
- Function code: 04 first, then 03
- Address mode: zero-based first, then one-based

## Minimal read test set
- 35 (Output power)
- 53 (Today generated energy)
- 55 (Total generated energy)
- 40/44/48 (Grid L1/L2/L3 power)

## Acceptance
- At least one register returns stable values over repeated polls.

## If all TCP reads fail
- Confirm logger-side third-party single-device control option.
- Confirm no client/session lock from other polling source.
- Fall back to RS485 for control path.
