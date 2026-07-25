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

function Get-HighByte {
  param([int]$Value)
  return [byte][math]::Floor($Value / 256)
}

function Get-LowByte {
  param([int]$Value)
  return [byte]($Value % 256)
}

function Combine-UInt16 {
  param(
    [byte]$High,
    [byte]$Low
  )

  return [UInt16](([int]$High * 256) + [int]$Low)
}

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

  $header = New-Object byte[] 7
  $header[0] = Get-HighByte $transactionValue
  $header[1] = Get-LowByte $transactionValue
  $header[2] = 0x00
  $header[3] = 0x00
  $header[4] = Get-HighByte $lengthValue
  $header[5] = Get-LowByte $lengthValue
  $header[6] = $Unit

  return $header + $Pdu
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
  $tx = Combine-UInt16 -High $header[0] -Low $header[1]
  if ($tx -ne $ExpectedTransactionId) {
    throw "Transaction mismatch. Expected $ExpectedTransactionId, got $tx."
  }

  $length = Combine-UInt16 -High $header[4] -Low $header[5]
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
    (Get-HighByte $addressValue),
    (Get-LowByte $addressValue),
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

  return Combine-UInt16 -High $res.Pdu[2] -Low $res.Pdu[3]
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
    (Get-HighByte $addressValue),
    (Get-LowByte $addressValue),
    (Get-HighByte $valueValue),
    (Get-LowByte $valueValue)
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

  $addrEcho = Combine-UInt16 -High $res.Pdu[1] -Low $res.Pdu[2]
  $valueEcho = Combine-UInt16 -High $res.Pdu[3] -Low $res.Pdu[4]

  if ($addrEcho -ne $Address -or $valueEcho -ne $Value) {
    throw "Write echo mismatch. Address echo: $addrEcho, value echo: $valueEcho"
  }
}

$tx = [UInt16]1
function Next-TransactionId {
  $script:tx = [UInt16](($script:tx + 1) % 65536)
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
