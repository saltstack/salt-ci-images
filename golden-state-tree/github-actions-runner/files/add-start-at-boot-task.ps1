$taskName = "Start GitHub Actions Runner"
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$action = New-ScheduledTaskAction -WorkingDirectory "C:\actions-runner" -Execute 'Powershell.exe' -Argument "-NoProfile -File ""C:\start-runner.ps1"""
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName $taskName -Description $taskName
