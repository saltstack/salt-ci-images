
<#PSScriptInfo

.VERSION 1.0.5

.GUID 799d13d4-1b5b-419e-aed5-78f839d930d3

.AUTHOR Tom-Inge Larsen

.COMPANYNAME

.COPYRIGHT (c) Tom-Inge Larsen

.TAGS install git installer

.LICENSEURI https://github.com/tomlarse/Install-Git/blob/master/LICENSE

.PROJECTURI https://github.com/tomlarse/Install-Git

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
    1.0.5 Added separate License file
    1.0.4 Added example to description
    1.0.3 TLS 1.2 fix, thanks jmangan68!
    1.0.2 Update to accomodate new git version patterns
    1.0.0 Initial release.

#>

<#

.SYNOPSIS
    Installs or updates git for windows.
.DESCRIPTION
    Borrowed heavily from https://github.com/PowerShell/vscode-powershell/blob/develop/scripts/Install-VSCode.ps1. Sourcecode available at https://github.com/tomlarse/Install-Git
    Install and run with Install-Script Install-Git; Install-Git.ps1
.EXAMPLE
    Install-Git.ps1
.NOTES
    This script is licensed under the MIT License:
    Copyright (c) Tom-Inge Larsen
    Copyright (c) Microsoft Corporation.
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
#>
Param()
if (!($IsLinux -or $IsOSX))
{

    $gitExePath = "C:\Program Files\Git\bin\git.exe"

    #Added TLS negotiation Fork jmangan68
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

    $dlurl = 'https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe'
    try
    {
        $ProgressPreference = 'SilentlyContinue'

        if (!(Test-Path $gitExePath))
        {
            Write-Host "`nDownloading latest stable git..." -ForegroundColor Yellow
            Remove-Item -Force $env:TEMP\git-stable.exe -ErrorAction SilentlyContinue
            Invoke-WebRequest -Uri $dlurl -OutFile $env:TEMP\git-stable.exe

            Write-Host "`nInstalling git..." -ForegroundColor Yellow
            Start-Process -Wait $env:TEMP\git-stable.exe -ArgumentList /silent
        }
        Write-Host "`nInstallation complete!`n`n" -ForegroundColor Green
    }
    finally
    {
        $ProgressPreference = 'Continue'
    }
}
else
{
    Write-Error "This script is currently only supported on the Windows operating system."
}
