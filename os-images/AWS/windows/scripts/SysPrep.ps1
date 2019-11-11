Enable-ScheduledTask "Download EC2 PubKey"

$EC2ConfigDir = [io.path]::combine($env:ProgramFiles, 'Amazon', 'Ec2ConfigService')
$EC2WindowsLaunch = [io.path]::combine($env:ProgramData, 'Amazon', 'EC2-Windows', 'Launch')

if (Test-Path $EC2ConfigDir) {
  $EXECUTABLE = [io.path]::combine($EC2ConfigDir, 'ec2config.exe')
  Write-Host "Executing $EXECUTABLE -sysprep"
  & cmd.exe /c "`"$EXECUTABLE`" -sysprep"
  if ($LASTEXITCODE -ne 0) {
    throw("Failed to run ec2config.exe -sysprep")
  }
}
ElseIf (Test-Path $EC2WindowsLaunch) {
  Write-Host "Running InitializeInstance"
  $InitializeInstanceScript = [io.path]::combine($EC2WindowsLaunch, 'Scripts', 'InitializeInstance.ps1')
  & Powershell.exe $InitializeInstanceScript -Schedule
  if ($LASTEXITCODE -ne 0) {
    throw("Failed to run InitializeInstance")
  }

  Write-Host "Running Sysprep Instance"
  $SysprepInstanceScript = [io.path]::combine($EC2WindowsLaunch, 'Scripts', 'SysprepInstance.ps1')
  & Powershell.exe $SysprepInstanceScript -NoShutdown
  if ($LASTEXITCODE -ne 0) {
    throw("Failed to run Sysprep")
  }
}
Else {
  throw("Neither $EC2ConfigDir nor $EC2WindowsLaunch were found")
}
