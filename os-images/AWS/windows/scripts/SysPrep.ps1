$EC2LaunchDir = [io.path]::combine($env:ProgramFiles, 'Amazon', 'EC2Launch')
$EC2ConfigDir = [io.path]::combine($env:ProgramFiles, 'Amazon', 'Ec2ConfigService')
$EC2WindowsLaunch = [io.path]::combine($env:ProgramData, 'Amazon', 'EC2-Windows', 'Launch')

if (Test-Path $EC2LaunchDir) {
  # Windows Server 2022
  $EXECUTABLE = [io.path]::combine($EC2LaunchDir, 'ec2launch.exe')
  Write-Host "Executing $EXECUTABLE sysprep --clean"
  & cmd.exe /c "`"$EXECUTABLE`" sysprep --clean"
  if ($LASTEXITCODE -ne 0) {
    throw("Failed to run ec2launch.exe sysprep --clean")
  }
}
ElseIf (Test-Path $EC2WindowsLaunch) {
  # Windows 2019
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
ElseIf (Test-Path $EC2ConfigDir) {
  # Windows 2016
  $EXECUTABLE = [io.path]::combine($EC2ConfigDir, 'ec2config.exe')
  Write-Host "Executing $EXECUTABLE -sysprep"
  & cmd.exe /c "`"$EXECUTABLE`" -sysprep"
  if ($LASTEXITCODE -ne 0) {
    throw("Failed to run ec2config.exe -sysprep")
  }
}
Else {
  throw("Neither $EC2LaunchDir nor $EC2ConfigDir nor $EC2WindowsLaunch were found")
}
Enable-ScheduledJob "Download EC2 PubKey"
Get-ScheduledJob | where state -eq 'Ready'
