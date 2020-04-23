$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Run-Process
{
  [CmdletBinding()]
  Param
  (
       [Parameter(Mandatory=$true, Position=0)]
       [string] $Executable,
       [Parameter(Mandatory=$true, Position=1)]
       [String] $Arguments,
       [Parameter(Mandatory=$false, Position=3)]
       [Switch] $SkipResultCheck
  )

  Write-Host "`nRunning Command: '$Executable $Arguments'" -ForegroundColor Yellow

  $proc = Start-Process $Executable -ArgumentList $Arguments -NoNewWindow -Wait -PassThru
  if ( -not $SkipResultCheck ) {
    if ( -not ( $proc.ExitCode -eq 0 ) ) {
      Start-Sleep -Second 1
      $ExitCode = $proc.ExitCode
      throw "Failed to run '$Executable $Arguments'. ExitCode: $ExitCode"
    }
  }
  Write-Host "`nRunning Command '$Executable $Arguments' Succeeded!" -ForegroundColor Yellow
}

$SRC = "https://repo.saltstack.com/windows/Salt-Minion-$Env:SALT_VERSION-Py$Env:SALT_PY_VERSION-AMD64-Setup.exe"
$DST = "$Env:TEMP\salt-$Env:SALT_VERSION.exe"
Write-Host "`nDownloading $SRC ..." -ForegroundColor Yellow
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($SRC, $DST)

Get-ChildItem -Path $Env:TEMP

Write-Host "`nInstalling Salt $Env:SALT_VERSION ..." -ForegroundColor Yellow
Run-Process -Executable $DST -Arguments "/S /start-minion=0"
