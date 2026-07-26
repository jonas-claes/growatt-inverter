param(
  [Parameter(Mandatory = $true)]
  [string]$IpAddress,

  [int]$Port = 502,
  [int[]]$UnitIds = @(0, 1, 2, 10),
  [int[]]$FunctionCodes = @(3, 4),
  [int[]]$Registers = @(0, 1, 3000, 3049),
  [int]$TimeoutMs = 2500
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

$results = @()

foreach ($u in $UnitIds) {
  foreach ($fc in $FunctionCodes) {
    foreach ($reg in $Registers) {
      foreach ($zeroBased in @($false, $true)) {
        $args = @(
          "-ExecutionPolicy", "Bypass",
          "-File", ".\\scripts\\tcp-read-register.ps1",
          "-IpAddress", $IpAddress,
          "-Port", $Port,
          "-UnitId", $u,
          "-Register", $reg,
          "-FunctionCode", $fc,
          "-TimeoutMs", $TimeoutMs,
          "-Retries", 1
        )

        if ($zeroBased) {
          $args += "-ZeroBasedAddress"
        }

        $ok = $false
        $message = ""
        try {
          $out = & powershell @args 2>&1
          $ok = $LASTEXITCODE -eq 0
          $message = ($out | Out-String).Trim()
        }
        catch {
          $ok = $false
          $message = $_.Exception.Message
        }

        $results += [PSCustomObject]@{
          UnitId = $u
          FunctionCode = $fc
          Register = $reg
          ZeroBased = $zeroBased
          Success = $ok
          Message = $message
        }

        if ($ok) {
          "Working combination found: UnitId=$u FC=$fc Register=$reg ZeroBased=$zeroBased"
          $results | Format-Table -AutoSize
          exit 0
        }
      }
    }
  }
}

"No working Modbus read combination found with current probe matrix."
$results | Format-Table -AutoSize
exit 1
