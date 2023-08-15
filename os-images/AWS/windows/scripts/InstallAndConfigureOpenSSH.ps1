Write-Host -NoNewline "Who Am I? "
& whoami

# Version and download URL
$OPENSSH_VERSION = "9.2.2.0p1-Beta"
$OPENSSH_URL = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v$OPENSSH_VERSION/OpenSSH-Win64.zip"

# GitHub became TLS 1.2 only on Feb 22, 2018
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# Function to unzip an archive to a given destination
Add-Type -AssemblyName System.IO.Compression.FileSystem
Function Unzip
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $ZipFile,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $OutPath
    )

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $outPath)
}

# Set various known paths
$OPENSSH_ZIP = Join-Path $env:TEMP 'OpenSSH.zip'
$DATA_DIR = [io.path]::combine($env:ProgramData, 'ssh')
$INSTALL_DIR = [io.path]::combine($env:ProgramFiles, 'OpenSSH')
$INSTALL_SSHD_SCRIPT_PATH = Join-Path $INSTALL_DIR 'install-sshd.ps1'
$DOWNLOAD_KEYS_SCRIPT = Join-Path $INSTALL_DIR 'download-ec2-pubkey.ps1'
$OPENSSH_DAEMON_EXE = Join-Path $INSTALL_DIR 'sshd.exe'

# Download and unpack the binary distribution of OpenSSH
Write-Host "Downloading $OPENSSH_URL to $OPENSSH_ZIP"
Invoke-WebRequest -Uri $OPENSSH_URL `
    -OutFile $OPENSSH_ZIP `
    -ErrorAction Stop

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download OpenSSH Server from $OPENSSH_URL"
    exit 1
}

Write-Host "Unzipping $OPENSSH_ZIP to $INSTALL_DIR"
Unzip -ZipFile $OPENSSH_ZIP `
    -OutPath "$INSTALL_DIR" `
    -ErrorAction Stop

if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Unzipping $OPENSSH_ZIP to $INSTALL_DIR"
    exit 1
}

Remove-Item $OPENSSH_ZIP `
    -ErrorAction SilentlyContinue

# Move into Program Files
Write-Host "Copying $INSTALL_DIR\OpenSSH-Win64\* to $INSTALL_DIR\"
Copy-Item -Path "$INSTALL_DIR\OpenSSH-Win64\*" `
  -Destination "$INSTALL_DIR\" `
  -Recurse `
  -Force `
  -ErrorAction Stop

if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Copying $INSTALL_DIR\OpenSSH-Win64\* to $INSTALL_DIR\"
    exit 1
}
Write-Host "Deleting $INSTALL_DIR\OpenSSH-Win64"
Remove-Item -Path "$INSTALL_DIR\OpenSSH-Win64" `
  -Recurse `
  -Force `
  -ErrorAction Stop

if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Deleting $INSTALL_DIR\OpenSSH-Win64"
    exit 1
}

& icacls $INSTALL_DIR

# Run the install script, terminate if it fails
Write-Host "Running Powershell.exe -ExecutionPolicy Bypass -File $INSTALL_SSHD_SCRIPT_PATH"
& Powershell.exe -ExecutionPolicy Bypass -File $INSTALL_SSHD_SCRIPT_PATH
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to install OpenSSH Server"
    exit 1
}

& icacls $INSTALL_DIR

# Add a firewall rule to allow inbound SSH connections to sshd.exe
New-NetFirewallRule -Name sshd `
    -DisplayName "OpenSSH Server (sshd)" `
    -Group "Remote Access" `
    -Description "Allow access via TCP port 22 to the OpenSSH Daemon" `
    -Enabled True `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 22 `
    -Program "$OPENSSH_DAEMON_EXE" `
    -Action Allow `
    -ErrorAction Stop

# Ensure sshd automatically starts on boot
Set-Service sshd -StartupType Automatic `
    -ErrorAction Stop

# Set the default login shell for SSH connections to Powershell
New-Item -Path HKLM:\SOFTWARE\OpenSSH -Force
New-ItemProperty -Path HKLM:\SOFTWARE\OpenSSH `
    -Name DefaultShell `
#    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -Value "C:\Program Files\Git\bin\bash.exe" `
    -ErrorAction Stop

# Make sure ssh's program data dir is populated
Start-Service sshd -ErrorAction Stop
if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Start-Service sshd"
    exit 1
}
Start-Sleep -Seconds 5
Stop-Service sshd -ErrorAction Stop
if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Stop-Service sshd"
    exit 1
}

$SSHD_CONFIG = [io.path]::combine($DATA_DIR, 'sshd_config')
$SSHD_CONFIG_EXTRA = @'
Match All
# We need the above line to terminate the default match block above

# Log to %PROGRAMDATA%\ssh\logs
SyslogFacility LOCAL0
# Very verbose logging
LogLevel DEBUG3
'@
# Un-comment below for debug logs
#$SSHD_CONFIG_EXTRA | Out-File -Append -FilePath $SSHD_CONFIG -Encoding ASCII

# Ensure access control on administrators_authorized_keys meets the requirements
$OPENSSH_UTILS_MODULE = [io.path]::combine($INSTALL_DIR, 'OpenSSHUtils.psd1')

Import-Module $OPENSSH_UTILS_MODULE -Force
Repair-SshdConfigPermission -FilePath $SSHD_CONFIG -Confirm:$false

Get-ChildItem $DATA_DIR\ssh_host_*_key -ErrorAction SilentlyContinue | % {
  Repair-SshdHostKeyPermission -FilePath $_.FullName -Confirm:$false
}

$keyDownloadScript = @'
$INSTALL_DIR = [io.path]::combine($env:ProgramFiles, 'OpenSSH')
$OPENSSH_UTILS_MODULE = [io.path]::combine($INSTALL_DIR, 'OpenSSHUtils.psd1')

Import-Module $OPENSSH_UTILS_MODULE -Force
# Download the instance key pair and authorize Administrator logins using it

$ProgramDataDir = $env:ProgramData
$openSSHAdminUser = Join-Path $ProgramDataDir "ssh"
$openSSHAuthorizedKeys = Join-Path $openSSHAdminUser 'administrators_authorized_keys'

If (-Not (Test-Path $openSSHAdminUser)) {
    New-Item -Path $openSSHAdminUser -Type Directory
}

Write-Host "Retrieving TOKEN from AWS API"
$token=Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "180"}

Write-Host "Downloading the current EC2 Instance Public Key from AWS"
Invoke-WebRequest "http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key" -Headers @{"X-aws-ec2-metadata-token" = $token} -Outfile $openSSHAuthorizedKeys
Write-Host "EC2 Instance Public Key Written To $openSSHAuthorizedKeys"

# Ensure access control on administrators_authorized_keys meets the requirements
Write-Host "Repairing permissions on $openSSHAuthorizedKeys"
Repair-AdministratorsAuthorizedKeysPermission -FilePath $openSSHAuthorizedKeys -Confirm:$false

Disable-ScheduledTask -TaskName "Download EC2 PubKey"
'@
$keyDownloadScript | Out-File $DOWNLOAD_KEYS_SCRIPT

# Create Task - Ensure the name matches the verbatim version above
$taskName = "Download EC2 PubKey"
$principal = New-ScheduledTaskPrincipal `
    -UserID "NT AUTHORITY\SYSTEM" `
    -LogonType ServiceAccount `
    -RunLevel Highest
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument "-NoProfile -File ""$DOWNLOAD_KEYS_SCRIPT"""
$trigger =  New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -TaskName $taskName `
    -Description $taskName
Disable-ScheduledTask -TaskName $taskName

# Run the download keys script, terminate if it fails
& Powershell.exe -ExecutionPolicy Bypass -File $DOWNLOAD_KEYS_SCRIPT
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download key pair"
    exit 1
}

# Make sure sshd starts after all the changes we did
Start-Service sshd -ErrorAction Stop
if ($LASTEXITCODE -ne 0) {
    Write-Error "FAILED: Start-Service sshd (after our changes to perms and config)"
    exit 1
}


# Clear the keys file from it's content
$openSSHAuthorizedKeys = [io.path]::combine($env:ProgramData, 'ssh', 'administrators_authorized_keys')
Write-Host "Wiping the contents of $openSSHAuthorizedKeys"
Clear-Content $openSSHAuthorizedKeys -ErrorAction Stop

Write-Host "Repairing permissions on $openSSHAuthorizedKeys"
Repair-AdministratorsAuthorizedKeysPermission -FilePath $openSSHAuthorizedKeys -Confirm:$false
Write-Host "Permissions on $openSSHAuthorizedKeys repaired"
exit 0
