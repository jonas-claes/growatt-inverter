param(
  [Parameter(Mandatory = $true)]
  [string]$IpAddress,

  [int]$Port = 502,

  [ValidateRange(1, 247)]
  [int]$UnitId = 1,

  [Parameter(Mandatory = $true)]
  [ValidateRange(0, 65535)]
  [int]$Register,

  [int]$TimeoutMs = 5000
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

$tx = [UInt16]2
[int]$registerValue = $Register
$pdu = [byte[]]@(
  0x03,
  (Get-HighByte $registerValue),
  (Get-LowByte $registerValue),
  0x00,
  0x01
)

$req = New-MbapHeader -TransactionId $tx -Unit ([byte]$UnitId) -Pdu $pdu

$client = [System.Net.Sockets.TcpClient]::new()
$client.ReceiveTimeout = $TimeoutMs
$client.SendTimeout = $TimeoutMs

try {
  $client.Connect($IpAddress, $Port)
  $stream = $client.GetStream()
  $res = Invoke-ModbusRequest -Stream $stream -Request $req -ExpectedTransactionId $tx

  $fc = $res.Pdu[0]
  if ($fc -eq 0x83) {
    throw "Modbus exception on read (FC03). Code: $($res.Pdu[1])."
  }
  if ($fc -ne 0x03 -or $res.Pdu[1] -ne 0x02) {
    throw "Unexpected read response format."
  }

  $value = Combine-UInt16 -High $res.Pdu[2] -Low $res.Pdu[3]

  [PSCustomObject]@{
    Target = "$IpAddress`:$Port"
    UnitId = $UnitId
    Register = $Register
    Value = $value
    Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
  } | Format-List
}
finally {
  if ($client.Connected) {
    $client.Close()
  }
}
