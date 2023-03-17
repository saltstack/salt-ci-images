$ErrorActionPreference = "Stop"

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

Write-Host "Installing NuGet Package Provider" -ForegroundColor Yellow
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Host "Installing DockerMsftProvider" -ForegroundColor Yellow
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

Write-Host "Installing Docker" -ForegroundColor Yellow
Install-Package -Name docker -ProviderName DockerMsftProvider -Force
