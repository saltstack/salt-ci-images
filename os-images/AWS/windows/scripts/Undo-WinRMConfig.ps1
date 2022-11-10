<#
.SYNOPSIS
  Revert WinRM to a pristine state.
  See this post for full details on why this code is helpful: https://cloudywindows.io/winrm-for-provisioning---close-the-door-on-the-way-out-eh/
.DESCRIPTION
  CloudyWindows.io DevOps Automation: https://github.com/DarwinJS/CloudyWindowsAutomationCode
  Why and How Blog Post: https://cloudywindows.io/winrm-for-provisioning---close-the-door-when-you-are-done-eh/
  Invoke-Expression (Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/blob/master/Undo-WinRMConfig/Undo-WinRMConfig.ps1')
  Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/blob/master/Undo-WinRMConfig/Undo-WinRMConfig.ps1' -outfile $env:public\Undo-WinRMConfig.ps1 ; & $env:public\Undo-WinRMConfig.ps1 -immediately
  Contributing New Undo Profiles: https://github.com/DarwinJS/Undo-WinRMConfig/blob/master/readme.md

  Disclaimer - this code was engineered and tested on Server 2012 R2 and Server 2016.

  Many windows remote orchestration tools (e.g. Packer) instruct you to completely open up winrm permissions in a way that is not safe for production.
  Usually there is no built in method nor instruction on how to re-secure it or shut it back down.
  The assumption most likely being that you would handle proper configuration as a part of production deployment.
  This is not a least privileged approach - depending on how big your company is and how widely your hypervisor templates are used - this is a disaster waiting to happen.  So I feel leaving it in a disabled state by default is the far safer option.
  To complicate things, if you attempt to secure winrm or shut it down as your last step in orchestration you slam the door on the orchestration system and it marks the attempt as a failure.
  Due to imprecise timing, start up tasks that disable winrm could conflict with a subsequent attempt to re-enable it on the next boot for final configuration steps (especially if you are building a hypervisor template).
  This self-deleting shutdown task performs the disable on the first shutdown and deletes itself.
  If a system shutsdown extremely quickly there is some risk that the shutdown job would not be deleted - but in testing on AWS (very fast shutdown), there have not been an observed problems.
  Updates and more information on ways to use this script are here: https://github.com/DarwinJS/CloudyWindowsAutomationCode/blob/master/Undo-WinRMConfig/readme.md
.COMPONENT
   CloudyWindows.io
.ROLE
  Provisioning Automation
.PARAMETER RunImmediately
  Specifies list of semi-colon seperated number ids of local Devices to initialize.  Devices appear in HKLM:SYSTEM\CurrentControlSet\Services\disk\Enum.
.PARAMETER RemoveShutdownScriptConfig
  Cancels running the script at the next shutdown by removing the shutdown configuration and files
.PARAMETER Version
  Emits the version and exits.
.EXAMPLE
  Invoke-Expression (invoke-webrequest -uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/blob/master/Undo-WinRMConfig/Undo-WinRMConfig.ps1')

  Run directly from github with no parameters - sets up shutdown script to reseal winRM.
.EXAMPLE
  Invoke-webrequest -uri 'https://raw.githubusercontent.com/DarwinJS/Undo-WinRMConfig/blob/master/Undo-WinRMConfig/Undo-WinRMConfig.ps1' -outfile $env:public\Undo-WinRMConfig.ps1 ; & $env:public\Undo-WinRMConfig.ps1 -immediately

  Download dynamically from github and run immediately.
#>
Param (
  [switch]$RunImmediately,
  [switch]$RemoveShutdownScriptConfig,
  [switch]$Version
)

$ThisScriptVersion = '1.2.0'

If ($version)
{
  Write-Host "$ThisScriptVersion"
  Exit 0
}

Function Setup-Undo {

  Write-Host "`r`n`r`nUndo-WinRMConfig Version $ThisScriptVersion`r`n`r`n"

  #This has to work for Win7 (no get-ciminstance) and Nano (no get-wmiobject) - each of which specially construct win32_operatingsystem.version to handle before and after Windows 10 version numbers (which are in different registry keys)
  If ($psversiontable.psversion.major -lt 3)
  { $OSMajorMinorVersionString = @(([version](Get-WMIObject Win32_OperatingSystem).version).major,([version](Get-WMIObject Win32_OperatingSystem).version).minor) -join '.' }
  Else
  { $OSMajorMinorVersionString = @(([version](Get-CIMInstance Win32_OperatingSystem).version).major,([version](Get-CIMInstance Win32_OperatingSystem).version).minor) -join '.' }

  If (!(Test-Path "variable:Pristine-WSMan-${OSMajorMinorVersionString}.reg"))
  {
    Throw "Undo-WinRMConfig does not have Pristine WSMan .REG file for your OS version $OSMajorMinorVersionString, if you would like to create and contribute one, please see: "
    Exit 5
  }

  #Build the undo script based on parameters
  [string]$UndoWinRMScript = @'

  If (!$PSScriptRoot) {$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent}

  #This has to work for Win7 (no get-ciminstance) and Nano (no get-wmiobject) - each of which specially construct win32_operatingsystem.version to handle before and after Windows 10 version numbers (which are in different registry keys)
  If ($psversiontable.psversion.major -lt 3)
  { $OSMajorMinorVersionString = @(([version](Get-WMIObject Win32_OperatingSystem).version).major,([version](Get-WMIObject Win32_OperatingSystem).version).minor) -join '.' }
  Else
  { $OSMajorMinorVersionString = @(([version](Get-CIMInstance Win32_OperatingSystem).version).major,([version](Get-CIMInstance Win32_OperatingSystem).version).minor) -join '.' }

  Write-Host "Disabling all Enabled Firewall rules that address port 5985 or 5896 directly"
  $EnabledInboundRMPorts = @(New-object -comObject HNetCfg.FwPolicy2).rules | where-object {($_.LocalPorts -ilike '*5985*') -AND ($_.Enabled -ilike 'True')}
  $EnabledInboundRMPorts += @(New-object -comObject HNetCfg.FwPolicy2).rules | where-object {($_.LocalPorts -ilike '*5986*') -AND ($_.Enabled -ilike 'True')}

  ForEach ($FirewallRuleName in $EnabledInboundRMPorts)
  {
    Write-Host "Disabling firewall rule that addresses remoting: `"$($FirewallRuleName.Name)`""
    netsh advfirewall firewall set rule name="$($FirewallRuleName.Name)" new enable=No
  }

  Write-Host "Undoing changes for Enable-PSRemoting, Enable-WSManCredSSP and winrm configuration commands"

  Write-Host "Remove LocalAccountTokenFilterPolicy added by winrm configuration"
  #This key is symlinked into "Wow6432Node" - both locations are handled by one delete
  $regkeypath ='HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system'
  If (!((Get-ItemProperty $regkeypath).LocalAccountTokenFilterPolicy -eq $null))
  {Remove-ItemProperty -path $regkeypath -name LocalAccountTokenFilterPolicy}

  Write-Host "Enable-PSRemoting changes will be removed by undoing WSMAN changes"
  Write-Host "Enable-WSManCredSSP client or server changes will be removed by undoing WSMAN changes"

  #Remove WSMAN Key before importing pristine .REG
  Remove-Item 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN' -Recurse -Force

  ForEach ($File in (Get-ChildItem "$PSScriptRoot\*${OSMajorMinorVersionString}.reg" | sort-object Name))
  {
    Write-Host "Importing $OSMajorMinorVersionString\$($File.name)"
    reg.exe import "$($File.fullname)"
  }
'@

  If ($RunImmediately)
  {
    Write-Output 'Undoing WinRM Config Right Now (do NOT execute this over remoting or this code will not complete)...'
    Invoke-Command -ScriptBlock [Scriptblock]::Create($UndoWinRMScript)
    exit 0
  }
  else
  {
    Write-Output 'Undoing WinRM Config On Next Shutdown'
  }

  #Write a file and call it in a machine shutdown script
  $psScriptsFile = "$env:windir\System32\GroupPolicy\Machine\Scripts\psscripts.ini"
  $Key1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\Scripts\Shutdown\0'
  $Key2 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine\Scripts\Shutdown\0'
  $keys = @($key1,$key2)
  $scriptpath = "$env:windir\System32\GroupPolicy\Machine\Scripts\Shutdown\Undo-WinRMConfig.ps1"
  $scriptfilename = (Split-Path -leaf $scriptpath)
  $ScriptFolder = (Split-Path -parent $scriptpath)
  $FileContents = Get-Variable -name "Pristine-WSMan-${OSMajorMinorVersionString}.reg" -ValueOnly
  New-Item -ItemType Directory -Force -Path $ScriptFolder
  Set-Content -Path "$ScriptFolder\Pristine-WSMan-${OSMajorMinorVersionString}.reg" -Value $FileContents

  $selfdeletescript = @"
  Start-Sleep -milliseconds 500
  Remove-Item -Path "$key1" -Force -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path "$key2" -Force -Recurse -ErrorAction SilentlyContinue
  Remove-Item -Path $scriptpath -Force  -ErrorAction SilentlyContinue
  Get-ChildItem "$env:windir\System32\GroupPolicy\Machine\Scripts\Shutdown\*${OSMajorMinorVersionString}.reg" | remove-item -force
  If (Test-Path $psScriptsFile)
  {
    (Get-Content "$psScriptsFile") -replace '0CmdLine=$scriptfilename', '' | Set-Content "$psScriptsFile"
    (Get-Content "$psScriptsFile") -replace '0Parameters=', '' | Set-Content "$psScriptsFile"
  }
"@

  $selfdeletescript =[Scriptblock]::Create($selfdeletescript)

  If ($RemoveShutdownScriptConfig)
  {
    Write-Host "Removing previously setup shutdown script"
    Invoke-Command -ScriptBlock $selfdeletescript
    exit $?
  }

  #Add the cleanup script block as a scheduled job executed immediately at the end of the shutdown script (if we aren't running immediately)
  $UndoWinRMScript += "Register-ScheduledJob -Name CleanUpWinRM -RunNow -ScheduledJobOption @{RunElevated=$True;ShowInTaskScheduler=$True;RunWithoutNetwork=$True} -ScriptBlock $selfdeletescript"

  Write-Host "Creating $scriptpath, with the following contents:"
  Write-Host '*******************'
  Write-Host "$UndoWinRMScript"
  Write-Host '*******************`r`n`r`n'
  If (!(Test-Path $ScriptFolder)) {New-Item $ScriptFolder -type Directory -force | Out-null}
  Set-Content -path $scriptpath -value $UndoWinRMScript

  Foreach ($Key in $keys)
  {
    Write-Host "Creating $Key"
    New-Item -Path $key -Force | out-null
    New-ItemProperty -Path $key -Name GPO-ID -Value LocalGPO -Force | out-null
    New-ItemProperty -Path $key -Name SOM-ID -Value Local -Force | out-null
    New-ItemProperty -Path $key -Name FileSysPath -Value "$env:windir\System32\GroupPolicy\Machine" -Force | out-null
    New-ItemProperty -Path $key -Name DisplayName -Value "Local Group Policy" -Force | out-null
    New-ItemProperty -Path $key -Name GPOName -Value "Local Group Policy" -Force | out-null
    New-ItemProperty -Path $key -Name PSScriptOrder -Value 1 -PropertyType "DWord" -Force | out-null

    $key = "$key\0"
    New-Item -Path $key -Force | out-null
    New-ItemProperty -Path $key -Name "Script" -Value $scriptfilename -Force | out-null
    New-ItemProperty -Path $key -Name "Parameters" -Value $parameters -Force | out-null
    New-ItemProperty -Path $key -Name "IsPowershell" -Value 1 -PropertyType "DWord" -Force | out-null
    New-ItemProperty -Path $key -Name "ExecTime" -Value 0 -PropertyType "QWord" -Force | out-null
  }

  Write-Host "Updating $psScriptsFile"
  If (!(Test-Path $psScriptsFile)) {New-Item $psScriptsFile -type file -force}
  "[Shutdown]" | Out-File $psScriptsFile
  "0CmdLine=$scriptfilename" | Out-File $psScriptsFile -Append
  "0Parameters=$parameters" | Out-File $psScriptsFile -Append

  Write-Host "`r`n`r`nUndo-WinRMConfig (v${ThisScriptVersion}) is staged to run at next shutdown.  To unstage, run 'Undo-WinRMConfig -RemoveShutdownScriptConfig'"
}

${Pristine-WSMan-10.0.reg} = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN]
"ServiceStackVersion"="3.0"
"StackVersion"="2.0"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\AutoRestartList]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\CertMapping]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Listener]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Listener\*+HTTP]
"Port"=dword:00001761
"uriprefix"="wsman"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Event Forwarding Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"C:\\Windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;ER)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources><Quotas MaxConcurrentUsers=\"2147483647\" MaxConcurrentOperationsPerUser=\"2147483647\" MaxConcurrentOperations=\"2147483647\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell]
"ConfigXML"="             <PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" Enabled=\"true\" >                 <InitializationParameters>                     <Param Name=\"PSVersion\" Value=\"5.1\"/>                 </InitializationParameters>                 <Resources>                     <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" SupportsOptions=\"true\" ExactMatch=\"true\">                         <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                         <Capability Type=\"Shell\"/>                     </Resource>                 </Resources>   <Quotas MaxMemoryPerShellMB=\"2147483647\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"2147483647\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"2147483647\" MaxConcurrentCommandsPerShell=\"2147483647\" MaxShells=\"2147483647\" MaxShellsPerUser=\"2147483647\"/>             </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell.Workflow]
"ConfigXML"="             <PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell.workflow\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" UseSharedProcess=\"true\" ProcessIdleTimeoutSec=\"1209600\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\"     Enabled=\"true\" >                 <InitializationParameters>                     <Param Name=\"PSVersion\" Value=\"5.1\"/>                     <Param Name=\"AssemblyName\" Value=\"Microsoft.PowerShell.Workflow.ServiceCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL\"/>                     <Param Name=\"PSSessionConfigurationTypeName\" Value=\"Microsoft.PowerShell.Workflow.PSWorkflowSessionConfiguration\"/>                     <Param Name=\"SessionConfigurationData\"                          Value=\"                             &lt;SessionConfigurationData&gt;                                 &lt;Param Name=&quot;ModulesToImport&quot; Value=&quot;%windir%\\system32\\windowspowershell\\v1.0\\Modules\\PSWorkflow&quot;/&gt;                                 &lt;Param Name=&quot;PrivateData&quot;&gt;                                     &lt;PrivateData&gt;                                         &lt;Param Name=&quot;enablevalidation&quot; Value=&quot;true&quot; /&gt;                                     &lt;/PrivateData&gt;                                 &lt;/Param&gt;                             &lt;/SessionConfigurationData&gt;                         \"                     />                 </InitializationParameters>                 <Resources>                     <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell.workflow\" SupportsOptions=\"true\" ExactMatch=\"true\">                         <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell.workflow\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                         <Capability Type=\"Shell\"/>                     </Resource>                 </Resources>     <Quotas MaxMemoryPerShellMB=\"2147483647\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"2147483647\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"2147483647\" MaxConcurrentCommandsPerShell=\"2147483647\" MaxShells=\"2147483647\" MaxShellsPerUser=\"2147483647\"/>             </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell32]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell32\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" Architecture=\"32\" Enabled=\"true\" >                         <InitializationParameters>                             <Param Name=\"PSVersion\" Value=\"5.1\"/>                         </InitializationParameters>                         <Resources>                             <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell32\" SupportsOptions=\"true\" ExactMatch=\"true\">                                 <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell32\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                                 <Capability Type=\"Shell\"/>                             </Resource>                         </Resources>    <Quotas MaxMemoryPerShellMB=\"2147483647\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"2147483647\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"2147483647\" MaxConcurrentCommandsPerShell=\"2147483647\" MaxShells=\"2147483647\" MaxShellsPerUser=\"2147483647\"/>                     </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.Windows.ServerManagerWorkflows]
"ConfigXML"="                     <PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.windows.servermanagerworkflows\" Filename=\"C:\\Windows\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" UseSharedProcess=\"true\" Enabled=\"true\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\"  >                         <InitializationParameters>                             <Param Name=\"PSVersion\" Value=\"3.0\"/>                             <Param Name=\"AssemblyName\" Value=\"Microsoft.Windows.ServerManager.Common, Version=10.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL\"/>                             <Param Name=\"PSSessionConfigurationTypeName\" Value=\"Microsoft.Windows.ServerManager.Common.Workflow.WorkflowSessionConfiguration\"/>                             <Param Name=\"SessionConfigurationData\"                                 Value=\"                                     &lt;SessionConfigurationData&gt;                                         &lt;Param Name=&quot;ModulesToImport&quot; Value=&quot;C:\\Windows\\\\system32\\\\ServerManagerInternal,C:\\Windows\\\\system32\\\\windowspowershell\\\\v1.0\\\\Modules\\\\PSWorkflow&quot; /&gt;                                         &lt;Param Name=&quot;PrivateData&quot;&gt;                                             &lt;PrivateData&gt;                                                 &lt;Param Name=&quot;allowedactivity&quot; Value=&quot;*&quot; /&gt;                                                 &lt;Param Name=&quot;outofprocessactivity&quot; Value=&quot;&quot; /&gt;                                             &lt;/PrivateData&gt;                                         &lt;/Param&gt;                                     &lt;/SessionConfigurationData&gt;                                 \"                             />                         </InitializationParameters>                         <Resources>                             <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.windows.servermanagerworkflows\" SupportsOptions=\"true\" ExactMatch=\"true\">                                 <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.windows.servermanagerworkflows\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                                 <Capability Type=\"Shell\"/>                             </Resource>                         </Resources>                         <Quotas MaxIdleTimeoutms=\"180000\" IdleTimeoutms=\"180000\" MaxConcurrentUsers=\"5\" MaxMemoryPerShellMB=\"2000\" MaxShells=\"100\" MaxProcessesPerShell=\"45\" MaxShellsPerUser=\"25\" MaxConcurrentCommandsPerShell=\"5000\"/>                     </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\SEL Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"C:\\Windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" > <Resources> <Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" > <Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /> <Capability Type=\"Subscribe\" /> </Resource> </Resources> <Quotas MaxConcurrentUsers=\"2147483647\" MaxConcurrentOperationsPerUser=\"2147483647\" MaxConcurrentOperations=\"2147483647\"/> </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\WMI Provider]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"C:\\Windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Identify\" /><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Create\" /><Capability Type=\"Delete\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/><Capability Type=\"Subscribe\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Create\" /><Capability Type=\"Delete\" /><Capability Type=\"Enumerate\"/><Capability Type=\"Subscribe\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/><Capability Type=\"Subscribe\"SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/cim-xml/2/cim-schema/2/*\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Get\" SupportsFragment=\"false\"/><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources><Quotas MaxConcurrentUsers=\"2147483647\" MaxConcurrentOperationsPerUser=\"2147483647\" MaxConcurrentOperations=\"2147483647\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\SafeClientList]
"WSManSafeClientList"=hex:00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,01

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Service]
"allow_remote_requests"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS\CustomRemoteShell]

'@

${Pristine-WSMan-6.3.reg} = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN]
"StackVersion"="2.0"
"ServiceStackVersion"="3.0"
"WtrPresent"=dword:00000000
"UpdatedConfig"="E6F6821F-51CC-4FEC-8E46-40C75C0CAD27"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\AutoRestartList]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\CertMapping]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Listener]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Listener\*+HTTP]
"hostname"=""
"uriprefix"="wsman"
"certThumbprint"=""
"Port"=dword:00001761
"enabled"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Event Forwarding Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"C:\\Windows\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;ER)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources><Quotas MaxConcurrentUsers=\"100\" MaxConcurrentOperationsPerUser=\"15\" MaxConcurrentOperations=\"1500\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" Enabled=\"true\" Architecture=\"64\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" RunAsVirtualAccount=\"false\" RunAsVirtualAccountGroups=\"\" AutoRestart=\"false\" OutputBufferingMode=\"Block\"><InitializationParameters><Param Name=\"PSVersion\" Value=\"5.0\"/></InitializationParameters><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/><Capability Type=\"Shell\"/></Resource></Resources><Quotas MaxMemoryPerShellMB=\"1024\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"5\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"15\" MaxConcurrentCommandsPerShell=\"1000\" MaxShells=\"25\" MaxShellsPerUser=\"25\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell.Workflow]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell.workflow\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" UseSharedProcess=\"true\" ProcessIdleTimeoutSec=\"1209600\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" Architecture=\"64\" RunAsVirtualAccount=\"false\" RunAsVirtualAccountGroups=\"\" OutputBufferingMode=\"Block\"><InitializationParameters><Param Name=\"PSVersion\" Value=\"5.0\"/><Param Name=\"AssemblyName\" Value=\"Microsoft.PowerShell.Workflow.ServiceCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL\"/><Param Name=\"PSSessionConfigurationTypeName\" Value=\"Microsoft.PowerShell.Workflow.PSWorkflowSessionConfiguration\"/><Param Name=\"SessionConfigurationData\" Value=\"                             &lt;SessionConfigurationData&gt;                                 &lt;Param Name=&quot;ModulesToImport&quot; Value=&quot;%windir%\\system32\\windowspowershell\\v1.0\\Modules\\PSWorkflow&quot;/&gt;                                 &lt;Param Name=&quot;PrivateData&quot;&gt;                                     &lt;PrivateData&gt;                                         &lt;Param Name=&quot;enablevalidation&quot; Value=&quot;true&quot; /&gt;                                     &lt;/PrivateData&gt;                                 &lt;/Param&gt;                             &lt;/SessionConfigurationData&gt;                         \"/></InitializationParameters><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell.workflow\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell.workflow\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/><Capability Type=\"Shell\"/></Resource></Resources><Quotas MaxMemoryPerShellMB=\"1024\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"5\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"15\" MaxConcurrentCommandsPerShell=\"1000\" MaxShells=\"25\" MaxShellsPerUser=\"25\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell32]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell32\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" Architecture=\"32\" Enabled=\"true\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" RunAsVirtualAccount=\"false\" RunAsVirtualAccountGroups=\"\" AutoRestart=\"false\" OutputBufferingMode=\"Block\"><InitializationParameters><Param Name=\"PSVersion\" Value=\"5.0\"/></InitializationParameters><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell32\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell32\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/><Capability Type=\"Shell\"/></Resource></Resources><Quotas MaxMemoryPerShellMB=\"1024\" MaxIdleTimeoutms=\"2147483647\" MaxConcurrentUsers=\"5\" IdleTimeoutms=\"7200000\" MaxProcessesPerShell=\"15\" MaxConcurrentCommandsPerShell=\"1000\" MaxShells=\"25\" MaxShellsPerUser=\"25\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.Windows.ServerManagerWorkflows]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.windows.servermanagerworkflows\" Filename=\"C:\\Windows\\system32\\pwrshplugin.dll\" SDKVersion=\"2\" XmlRenderingType=\"text\" UseSharedProcess=\"true\" Enabled=\"true\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Architecture=\"64\" ProcessIdleTimeoutSec=\"0\" RunAsVirtualAccount=\"false\" RunAsVirtualAccountGroups=\"\" OutputBufferingMode=\"Block\"><InitializationParameters><Param Name=\"PSVersion\" Value=\"3.0\"/><Param Name=\"AssemblyName\" Value=\"Microsoft.Windows.ServerManager.Common, Version=6.3.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL\"/><Param Name=\"PSSessionConfigurationTypeName\" Value=\"Microsoft.Windows.ServerManager.Common.Workflow.WorkflowSessionConfiguration\"/><Param Name=\"SessionConfigurationData\" Value=\"                                     &lt;SessionConfigurationData&gt;                                         &lt;Param Name=&quot;ModulesToImport&quot; Value=&quot;C:\\Windows\\\\system32\\\\ServerManagerInternal,C:\\Windows\\\\system32\\\\windowspowershell\\\\v1.0\\\\Modules\\\\PSWorkflow&quot; /&gt;                                         &lt;Param Name=&quot;PrivateData&quot;&gt;                                             &lt;PrivateData&gt;                                                 &lt;Param Name=&quot;allowedactivity&quot; Value=&quot;*&quot; /&gt;                                                 &lt;Param Name=&quot;outofprocessactivity&quot; Value=&quot;&quot; /&gt;                                             &lt;/PrivateData&gt;                                         &lt;/Param&gt;                                     &lt;/SessionConfigurationData&gt;                                 \"/></InitializationParameters><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.windows.servermanagerworkflows\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.windows.servermanagerworkflows\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/><Capability Type=\"Shell\"/></Resource></Resources><Quotas MaxIdleTimeoutms=\"180000\" IdleTimeoutms=\"180000\" MaxConcurrentUsers=\"5\" MaxMemoryPerShellMB=\"2000\" MaxShells=\"100\" MaxProcessesPerShell=\"45\" MaxShellsPerUser=\"25\" MaxConcurrentCommandsPerShell=\"5000\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\SEL Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"C:\\Windows\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" > <Resources> <Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" > <Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /> <Capability Type=\"Subscribe\" /> </Resource> </Resources> <Quotas MaxConcurrentUsers=\"100\" MaxConcurrentOperationsPerUser=\"15\" MaxConcurrentOperations=\"1500\"/> </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\WMI Provider]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"C:\\Windows\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" UseSharedProcess=\"false\" ProcessIdleTimeoutSec=\"0\" RunAsUser=\"\" RunAsPassword=\"\" AutoRestart=\"false\" Enabled=\"true\" OutputBufferingMode=\"Block\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Identify\" /><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Create\" /><Capability Type=\"Delete\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/><Capability Type=\"Subscribe\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Create\" /><Capability Type=\"Delete\" /><Capability Type=\"Enumerate\"/><Capability Type=\"Subscribe\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/><Capability Type=\"Subscribe\"SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/cim-xml/2/cim-schema/2/*\" SupportsOptions=\"true\" ExactMatch=\"true\"><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;IU)(A;;GA;;;RM)S:P(AU;FA;GA;;;WD)(AU;SA;GWGX;;;WD)\" /><Capability Type=\"Get\" SupportsFragment=\"false\"/><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources><Quotas MaxConcurrentUsers=\"100\" MaxConcurrentOperationsPerUser=\"100\" MaxConcurrentOperations=\"1500\"/></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\SafeClientList]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Service]
"allow_remote_requests"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS\CustomRemoteShell]

'@

${Pristine-WSMan-6.1.reg} = @'
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN]
"StackVersion"="2.0"
"SupportsCompatListeners"=dword:00000001
"UpdatedConfig"="58262FF8-3F83-4B48-A1FB-054FA5700982"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\CertMapping]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Client]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Listener]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Event Forwarding Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"Event Forwarding Plugin\" Filename=\"%systemroot%\\system32\\wevtfwd.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/windows/EventLog\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GR;;;ER)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" SupportsFiltering=\"true\" /></Resource></Resources></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.PowerShell]
"ConfigXML"="             <PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.powershell\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" >                 <InitializationParameters>                     <Param Name=\"PSVersion\" Value=\"2.0\"/>                 </InitializationParameters>                 <Resources>                     <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" SupportsOptions=\"true\" ExactMatch=\"true\">                         <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.powershell\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                         <Capability Type=\"Shell\"/>                     </Resource>                 </Resources>             </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\Microsoft.ServerManager]
"ConfigXML"="               <PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"microsoft.ServerManager\" Filename=\"%windir%\\system32\\pwrshplugin.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" >                   <InitializationParameters>                       <Param Name=\"PSVersion\" Value=\"2.0\"/>                       <Param Name=\"AssemblyName\" Value=\"Microsoft.Windows.ServerManager.PowerShell, Version=6.1.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL\" />                       <Param Name=\"PSSessionConfigurationTypeName\" Value=\"Microsoft.Windows.ServerManager.Commands.PowerShellCustomShell\" />                   </InitializationParameters>                   <Resources>                       <Resource ResourceUri=\"http://schemas.microsoft.com/powershell/microsoft.ServerManager\" SupportsOptions=\"true\" ExactMatch=\"true\">                           <Security xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Uri=\"http://schemas.microsoft.com/powershell/microsoft.ServerManager\" ExactMatch=\"true\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\"/>                           <Capability Type=\"Shell\"/>                       </Resource>                   </Resources>               </PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\SEL Plugin]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"SEL Plugin\" Filename=\"%systemroot%\\system32\\wsmselpl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/logrecord/sel\" SupportsOptions=\"true\" ><Security Uri=\"\" ExactMatch=\"false\" Sddl=\"O:NSG:BAD:P(A;;GA;;;BA)(A;;GA;;;S-1-5-80-4059739203-877974739-1245631912-527174227-2996563517)S:P(AU;FA;GA;;;WD)(AU;SA;GXGW;;;WD)\" /><Capability Type=\"Subscribe\" /></Resource></Resources></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Plugin\WMI Provider]
"ConfigXML"="<PlugInConfiguration xmlns=\"http://schemas.microsoft.com/wbem/wsman/1/config/PluginConfiguration\" Name=\"WMI Provider\" Filename=\"%systemroot%\\system32\\WsmWmiPl.dll\" SDKVersion=\"1\" XmlRenderingType=\"text\" ><Resources><Resource ResourceUri=\"http://schemas.microsoft.com/wbem/wsman/1/wmi\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/cim-schema\" SupportsOptions=\"true\" ><Capability Type=\"Get\" SupportsFragment=\"true\" /><Capability Type=\"Put\" SupportsFragment=\"true\" /><Capability Type=\"Invoke\" /><Capability Type=\"Enumerate\" /></Resource><Resource ResourceUri=\"http://schemas.dmtf.org/wbem/wscim/1/*\" SupportsOptions=\"true\" ExactMatch=\"true\" ><Capability Type=\"Enumerate\" SupportsFiltering=\"true\"/></Resource></Resources></PlugInConfiguration>"

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\Service]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS]

[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN\WinRS\CustomRemoteShell]

'@

Setup-Undo
