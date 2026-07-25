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

function New-MbapHeader {
  param(
    [UInt16]$TransactionId,
    [byte]$Unit,
    [byte[]]$Pdu
  )

  $length = [UInt16]($Pdu.Length + 1)
  return [byte[]]@(
    ($TransactionId -shr 8) -band 0xFF,
    $TransactionId -band 0xFF,
    0x00,
    0x00,
    ($length -shr 8) -band 0xFF,
    $length -band 0xFF,
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
  $tx = [UInt16](($header[0] -shl 8) -bor $header[1])
  if ($tx -ne $ExpectedTransactionId) {
    throw "Transaction mismatch. Expected $ExpectedTransactionId, got $tx."
  }

  $length = [UInt16](($header[4] -shl 8) -bor $header[5])
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
$pdu = [byte[]]@(
  0x03,
  ($Register -shr 8) -band 0xFF,
  $Register -band 0xFF,
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

  $value = [UInt16](($res.Pdu[2] -shl 8) -bor $res.Pdu[3])

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
