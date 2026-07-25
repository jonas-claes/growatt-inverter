# M3-T01 Connectivity Test (ShineWiLan-X2 Modbus TCP)

Task ID: M3-T01
Status: Executed (Blocked)

## Objective
Verify that the Modbus TCP endpoint is reachable and stable enough for controlled read/write validation.

## Preconditions
- Logger IP known.
- Test device on same network segment.
- Controlled time window where brief polling is acceptable.

## Step 1: Port Reachability
PowerShell:

```powershell
Test-NetConnection 192.168.1.102 -Port 502
```

Pass criteria:
- `TcpTestSucceeded` is `True`.

## Step 2: Baseline Socket Stability
PowerShell loop (20 attempts):

```powershell
1..20 | ForEach-Object {
  $r = Test-NetConnection 192.168.1.102 -Port 502 -WarningAction SilentlyContinue
  [PSCustomObject]@{
    Attempt = $_
    Success = $r.TcpTestSucceeded
    Remote = $r.RemoteAddress
  }
} | Format-Table -AutoSize
```

Pass criteria:
- >= 19/20 successful attempts.

## Step 3: Record Outcome
- Add result row to firmware matrix.
- If unstable, mark M3 blocked and investigate network or logger firmware.

## Observed Result (2026-07-25)
- Logger IP: 192.168.1.102
- Step 1: Passed (`TcpTestSucceeded = True`)
- Step 2: Failed stability threshold (4/20 successful)
- Outcome: TCP path is currently too unstable for read/write validation.
- Decision: Keep M3-T02 blocked until stability is restored.

## Output to capture
- Logger IP
- Step 1 output
- Success count from Step 2
- Date/time and tester initials

## Failure handling
- If Step 1 fails: stop M3 and check IP/network path.
- If Step 2 fails intermittently: continue read-only research, do not run write tests.
