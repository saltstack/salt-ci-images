$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

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

Write-Host "Installing cloudwatch agent..." -ForegroundColor Yellow
Invoke-WebRequest -Uri https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi -OutFile C:\amazon-cloudwatch-agent.msi
$cloudwatchParams = '/i', 'C:\amazon-cloudwatch-agent.msi', '/qn', '/L*v', 'C:\CloudwatchInstall.log'
Run-Process -Executable "msiexec.exe" -Arguments "/i C:\amazon-cloudwatch-agent.msi /qn /L*v C:\CloudwatchInstall.log"
Remove-Item C:\amazon-cloudwatch-agent.msi
