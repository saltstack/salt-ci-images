$ErrorActionPreference = "Stop"

$DST = "$Env:SALT_PY_TARGET_DIR\uninst.exe"

Get-ChildItem -Path $Env:TEMP

Write-Host "`nUn-Installing Salt $Env:SALT_VERSION ..." -ForegroundColor Yellow
$argument_list = "/S"
Write-Host "`nCommand: $DST $argument_list" -ForegroundColor Yellow
$result = Start-Process $DST -ArgumentList $argument_list  -NoNewWindow -Wait -PassThru
if (!($result.ExitCode -eq 0)) {
  Write-Host "`nFailed to uninstall Salt!" -ForegroundColor Red
  throw "Salt un-installation failed."
}
