$ErrorActionPreference = "Stop"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$SALT_ARCHIVE_NAME="salt-$Env:SALT_VERSION-onedir-windows-$Env:OS_ARCH.zip"
$SALT_DOWNLOAD_URL="https://repo.saltproject.io/salt/py3/onedir/minor/$Env:SALT_VERSION/$SALT_ARCHIVE_NAME"
$DST = "$Env:TEMP\$SALT_ARCHIVE_NAME"
Write-Host "`nDownloading $SALT_DOWNLOAD_URL ..." -ForegroundColor Yellow
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($SALT_DOWNLOAD_URL, $DST)

Write-Host "Contents of $Env:TEMP ..." -ForegroundColor Yellow
Get-ChildItem -Path $Env:TEMP

Write-Host "Extracting $SALT_ARCHIVE_NAME to $Env:TEMP\salt" -ForegroundColor Yellow
Expand-Archive -LiteralPath $DST -DestinationPath $Env:TEMP

Write-Host "Contents of $Env:TEMP\salt ..." -ForegroundColor Yellow
Get-ChildItem -Path $Env:TEMP\salt

Write-Host "Deleting $SALT_ARCHIVE_NAME" -ForegroundColor Yellow
Remove-Item $DST -Force
