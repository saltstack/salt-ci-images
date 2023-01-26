# Enable TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'

# Suppress the progress bar
$ProgressPreference = "SilentlyContinue"

$url = "https://files.gpg4win.org/gpg4win-4.1.0.exe"
$target = "gpg4win.exe"
$tmp = "C:\tmp"
$output = "$tmp\$target"

Write-Host "gpg4win: Downloading installer" -ForegroundColor Yellow
Write-Host"- url: $url"
Write-Host"- output: $output"
Invoke-WebRequest -Uri $url -OutFile $output -Method Get

Write-Host "gpg4win: Creating control file" -ForegroundColor Yellow
$ini_file = "$tmp\gpg4win.ini"
$ini_contents = @"
[gpg4win]
inst_gpgol = false
inst_gpgex = false
"@
Set-Content -Path $ini_file -Value $ini_contents

Write-Host "gpg4win: Installing gpg4win" -ForegroundColor Yellow
Start-Process -FilePath $output `
              -ArgumentList "/S", "C=$ini_file" `
              -WindowStyle Hidden `
              -Wait

# Clean up
Write-Host "gpg4win: Cleaning up" -ForegroundColor Yellow
Remove-Item $output
Remove-Item $ini_file
