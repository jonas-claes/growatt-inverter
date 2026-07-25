# M3-T01 Connectivity Test (ShineWiLan-X2 Modbus TCP)

Task ID: M3-T01
Status: Ready for execution

## Objective
Verify that the Modbus TCP endpoint is reachable and stable enough for controlled read/write validation.

## Preconditions
- Logger IP known.
- Test device on same network segment.
- Controlled time window where brief polling is acceptable.

## Step 1: Port Reachability
PowerShell:

```powershell
Test-NetConnection <LOGGER_IP> -Port 502
```

Pass criteria:
- `TcpTestSucceeded` is `True`.

## Step 2: Baseline Socket Stability
PowerShell loop (20 attempts):

```powershell
1..20 | ForEach-Object {
  $r = Test-NetConnection <LOGGER_IP> -Port 502 -WarningAction SilentlyContinue
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

## Output to capture
- Logger IP
- Step 1 output
- Success count from Step 2
- Date/time and tester initials

## Failure handling
- If Step 1 fails: stop M3 and check IP/network path.
- If Step 2 fails intermittently: continue read-only research, do not run write tests.
