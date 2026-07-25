param(
  [Parameter(Mandatory = $true)]
  [string]$IpAddress,

  [int]$Port = 502,

  [ValidateRange(1, 247)]
  [int]$UnitId = 1,

  [Parameter(Mandatory = $true)]
  [ValidateRange(0, 65535)]
  [int]$WriteRegister,

  [Parameter(Mandatory = $true)]
  [ValidateRange(0, 65535)]
  [int]$TestValue,

  [Parameter(Mandatory = $true)]
  [ValidateRange(0, 65535)]
  [int]$RollbackValue,

  [ValidateRange(0, 65535)]
  [int]$ReadbackRegister = -1,

  [int]$DelayMs = 500,
  [int]$TimeoutMs = 5000,

  [switch]$ConfirmWrite,
  [switch]$SkipAfterWriteMatch
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($ReadbackRegister -lt 0) {
  $ReadbackRegister = $WriteRegister
}

if (-not $ConfirmWrite) {
  throw "Safety gate: add -ConfirmWrite to execute write operations."
}

function New-MbapHeader {
  param(
    [UInt16]$TransactionId,
    [byte]$Unit,
    [byte[]]$Pdu
  )

  [int]$transactionValue = $TransactionId
  [int]$lengthValue = $Pdu.Length + 1

  return [byte[]]@(
    [byte](($transactionValue -shr 8) -band 0xFF),
    [byte]($transactionValue -band 0xFF),
    0x00,
    0x00,
    [byte](($lengthValue -shr 8) -band 0xFF),
    [byte]($lengthValue -band 0xFF),
    $Unit
  ) + $Pdu
}

function Read-ExactBytes {
  param(
    [System.IO.Stream]$Stream,
    [int]$Count
  )

  $buffer = New-Object byte[] $Count
  $offset = 0
  while ($offset -lt $Count) {
    $read = $Stream.Read($buffer, $offset, $Count - $offset)
    if ($read -le 0) {
      throw "Connection closed while reading response."
    }
    $offset += $read
  }
  return $buffer
}

function Invoke-ModbusRequest {
  param(
    [System.IO.Stream]$Stream,
    [byte[]]$Request,
    [UInt16]$ExpectedTransactionId
  )

  $Stream.Write($Request, 0, $Request.Length)

  $header = Read-ExactBytes -Stream $Stream -Count 7
  $tx = [UInt16]((([int]$header[0]) -shl 8) -bor ([int]$header[1]))
  if ($tx -ne $ExpectedTransactionId) {
    throw "Transaction mismatch. Expected $ExpectedTransactionId, got $tx."
  }

  $length = [UInt16]((([int]$header[4]) -shl 8) -bor ([int]$header[5]))
  if ($length -lt 1) {
    throw "Invalid Modbus length in response."
  }

  $remaining = [int]$length - 1
  $pdu = Read-ExactBytes -Stream $Stream -Count $remaining
  return [PSCustomObject]@{
    UnitId = $header[6]
    Pdu = $pdu
  }
}

function Read-HoldingRegister {
  param(
    [System.IO.Stream]$Stream,
    [UInt16]$TransactionId,
    [byte]$Unit,
    [UInt16]$Address
  )

  [int]$addressValue = $Address
  $pdu = [byte[]]@(
    0x03,
    [byte](($addressValue -shr 8) -band 0xFF),
    [byte]($addressValue -band 0xFF),
    0x00,
    0x01
  )

  $req = New-MbapHeader -TransactionId $TransactionId -Unit $Unit -Pdu $pdu
  $res = Invoke-ModbusRequest -Stream $Stream -Request $req -ExpectedTransactionId $TransactionId

  $fc = $res.Pdu[0]
  if ($fc -eq 0x83) {
    throw "Modbus exception on read (FC03). Code: $($res.Pdu[1])."
  }
  if ($fc -ne 0x03 -or $res.Pdu[1] -ne 0x02) {
    throw "Unexpected read response format."
  }

  return [UInt16]((([int]$res.Pdu[2]) -shl 8) -bor ([int]$res.Pdu[3]))
}

function Write-SingleRegister {
  param(
    [System.IO.Stream]$Stream,
    [UInt16]$TransactionId,
    [byte]$Unit,
    [UInt16]$Address,
    [UInt16]$Value
  )

  [int]$addressValue = $Address
  [int]$valueValue = $Value
  $pdu = [byte[]]@(
    0x06,
    [byte](($addressValue -shr 8) -band 0xFF),
    [byte]($addressValue -band 0xFF),
    [byte](($valueValue -shr 8) -band 0xFF),
    [byte]($valueValue -band 0xFF)
  )

  $req = New-MbapHeader -TransactionId $TransactionId -Unit $Unit -Pdu $pdu
  $res = Invoke-ModbusRequest -Stream $Stream -Request $req -ExpectedTransactionId $TransactionId

  $fc = $res.Pdu[0]
  if ($fc -eq 0x86) {
    throw "Modbus exception on write (FC06). Code: $($res.Pdu[1])."
  }
  if ($fc -ne 0x06) {
    throw "Unexpected write response function code: $fc"
  }

  $addrEcho = [UInt16]((([int]$res.Pdu[1]) -shl 8) -bor ([int]$res.Pdu[2]))
  $valueEcho = [UInt16]((([int]$res.Pdu[3]) -shl 8) -bor ([int]$res.Pdu[4]))

  if ($addrEcho -ne $Address -or $valueEcho -ne $Value) {
    throw "Write echo mismatch. Address echo: $addrEcho, value echo: $valueEcho"
  }
}

$tx = [UInt16]1
function Next-TransactionId {
  $script:tx = [UInt16]((([int]$script:tx + 1) -band 0xFFFF))
  return $script:tx
}

$client = [System.Net.Sockets.TcpClient]::new()
$client.ReceiveTimeout = $TimeoutMs
$client.SendTimeout = $TimeoutMs

$baseline = $null
$afterWrite = $null
$afterRollback = $null
$verdict = "FAIL"

try {
  $client.Connect($IpAddress, $Port)
  $stream = $client.GetStream()

  $baseline = Read-HoldingRegister -Stream $stream -TransactionId (Next-TransactionId) -Unit ([byte]$UnitId) -Address ([UInt16]$ReadbackRegister)

  Write-SingleRegister -Stream $stream -TransactionId (Next-TransactionId) -Unit ([byte]$UnitId) -Address ([UInt16]$WriteRegister) -Value ([UInt16]$TestValue)
  Start-Sleep -Milliseconds $DelayMs

  $afterWrite = Read-HoldingRegister -Stream $stream -TransactionId (Next-TransactionId) -Unit ([byte]$UnitId) -Address ([UInt16]$ReadbackRegister)

  Write-SingleRegister -Stream $stream -TransactionId (Next-TransactionId) -Unit ([byte]$UnitId) -Address ([UInt16]$WriteRegister) -Value ([UInt16]$RollbackValue)
  Start-Sleep -Milliseconds $DelayMs

  $afterRollback = Read-HoldingRegister -Stream $stream -TransactionId (Next-TransactionId) -Unit ([byte]$UnitId) -Address ([UInt16]$ReadbackRegister)

  $rollbackOk = ($afterRollback -eq [UInt16]$RollbackValue) -or ($afterRollback -eq $baseline)
  $afterWriteOk = $SkipAfterWriteMatch -or ($afterWrite -eq [UInt16]$TestValue)

  if ($rollbackOk -and $afterWriteOk) {
    $verdict = "PASS"
  }
}
finally {
  if ($client.Connected) {
    $client.Close()
  }
}

[PSCustomObject]@{
  Target = "$IpAddress`:$Port"
  UnitId = $UnitId
  WriteRegister = $WriteRegister
  ReadbackRegister = $ReadbackRegister
  Baseline = $baseline
  TestValue = $TestValue
  ReadAfterWrite = $afterWrite
  RollbackValue = $RollbackValue
  ReadAfterRollback = $afterRollback
  Verdict = $verdict
} | Format-List

if ($verdict -ne "PASS") {
  throw "Safe write test failed. Keep M3-T02 blocked until issue is understood."
}
