$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"
$progressPreference = 'silentlyContinue'

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

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


Write-Host "Installing aws ssm agent..." -ForegroundColor Yellow
Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile c:\SSMAgent_latest.exe
Run-Process -Executable c:\SSMAgent_latest.exe -Arguments "/S"
Remove-Item -Force c:\SSMAgent_latest.exe
