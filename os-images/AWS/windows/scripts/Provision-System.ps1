$ErrorActionPreference = "Stop"

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

$SALT_CALL = "$Env:TMP\salt\salt-call.exe"
$CONFIG_DIR = "$Env:SALT_ROOT_DIR\conf"
$DEFAULT_ARGUMENTS = "--local --log-level=warning --config-dir=$CONFIG_DIR --retcode-passthrough"

Write-Host "`nBootstrapping Chocolatey" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS chocolatey.bootstrap"

Write-Host "`nUpdating Windows Git Repos" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS winrepo.update_git_repos"


Start-Sleep -Second 2
Write-Host "`nRefreshing Windows Package Database" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS pkg.refresh_db" -SkipResultCheck

Start-Sleep -Second 2
Write-Host "`nSync ALL" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS saltutil.sync_all" -SkipResultCheck

Start-Sleep -Second 2
Write-Host "`nGet Windows Repo Data" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS pkg.get_repo_data" -SkipResultCheck

Start-Sleep -Second 2
Write-Host "List Windows Repo States" -ForegroundColor Yellow
Get-ChildItem -Path $Env:SALT_ROOT_DIR\cache\files\base -Recurse

Start-Sleep -Second 2
Write-Host "`nProvisioning System" -ForegroundColor Yellow
Run-Process -Executable $SALT_CALL -Arguments "$DEFAULT_ARGUMENTS --file-root=$Env:SALT_ROOT_DIR\states --pillar-root=$Env:SALT_ROOT_DIR\pillar state.sls $Env:SALT_STATE"
