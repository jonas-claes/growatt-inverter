param(
  [Parameter(Mandatory = $true)]
  [string]$IpAddress,

  [int]$Port = 502,
  [int]$Attempts = 30,
  [int]$DelayMs = 1500
)

$results = @()
$consecutiveFailures = 0
$maxConsecutiveFailures = 0

for ($i = 1; $i -le $Attempts; $i++) {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $r = Test-NetConnection $IpAddress -Port $Port -WarningAction SilentlyContinue
  $sw.Stop()

  $ok = [bool]$r.TcpTestSucceeded
  if ($ok) {
    $consecutiveFailures = 0
  }
  else {
    $consecutiveFailures++
    if ($consecutiveFailures -gt $maxConsecutiveFailures) {
      $maxConsecutiveFailures = $consecutiveFailures
    }
  }

  $results += [PSCustomObject]@{
    Attempt = $i
    Success = $ok
    ConnectMs = [int]$sw.Elapsed.TotalMilliseconds
    Time = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  }

  Start-Sleep -Milliseconds $DelayMs
}

$successCount = ($results | Where-Object { $_.Success }).Count
$successRatio = [math]::Round(($successCount / $Attempts) * 100, 2)
$avgMs = [math]::Round((($results | Measure-Object -Property ConnectMs -Average).Average), 2)

$results | Format-Table -AutoSize
""
"Summary"
"-------"
"Target: $IpAddress`:$Port"
"Success: $successCount/$Attempts ($successRatio%)"
"Avg Connect Time: $avgMs ms"
"Max Consecutive Failures: $maxConsecutiveFailures"

if ($successRatio -ge 95) {
  "Verdict: PASS (M3-T02 may proceed)"
}
else {
  "Verdict: FAIL (keep M3-T02 blocked)"
}
