# M3-T01b Diagnostic Test (TCP Instability Isolation)

Task ID: M3-T01b
Status: In Progress (Wi-Fi executed, wired pending)

## Objective
Isolate whether Modbus TCP instability is caused by network path, endpoint connection limits, or timing/polling behavior.

## Preconditions
- Logger IP confirmed (current: 192.168.1.102).
- Run from the same machine and network used by Loxone if possible.
- Ensure no heavy simultaneous polling during test window.

## Test A: Slower connection probe
Run with pauses to avoid burst behavior:

```powershell
$ip = "192.168.1.102"
$ok = 0
1..20 | ForEach-Object {
  $r = Test-NetConnection $ip -Port 502 -WarningAction SilentlyContinue
  if ($r.TcpTestSucceeded) { $ok++ }
  Start-Sleep -Seconds 2
}
"Success=$ok/20"
```

Pass criteria:
- At least 19/20 succeeds.

## Test B: Continuous endpoint check with script
Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\tcp502-stability.ps1 -IpAddress 192.168.1.102 -Attempts 30 -DelayMs 1500
```

Pass criteria:
- Success ratio >= 95%.
- No long timeout streaks.

## Test C: Route sensitivity
Repeat Test B from:
- Wi-Fi client.
- Wired client (if available).

Compare results to detect WLAN-only instability.

## Output to capture
- Success ratio for each test run.
- Max consecutive failures.
- Average connect time.
- Wi-Fi vs wired comparison note.

## Observed Result (2026-07-25, Wi-Fi)
- Target: 192.168.1.102:502
- Success: 27/30 (90%)
- Average connect time: 12813.43 ms
- Max consecutive failures: 3
- Verdict: FAIL (keep M3-T02 blocked)

## Next Required Run
- Execute Test B from a wired client on the same LAN.
- Use the exact script command and capture full summary output.

## Decision rules
- If only Wi-Fi fails: classify as path issue, not inverter protocol issue.
- If both fail similarly: classify as endpoint/logger-side instability.
- If recovered to >=95%: unblock M3-T02.
