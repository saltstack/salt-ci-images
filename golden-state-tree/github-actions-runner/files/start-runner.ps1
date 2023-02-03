## Retrieve instance metadata

$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:/runner-startup.log -append

Write-Host  "Retrieving TOKEN from AWS API"
$token=Invoke-RestMethod -Method PUT -Uri "http://169.254.169.254/latest/api/token" -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "180"}

$ami_id=Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/ami-id" -Headers @{"X-aws-ec2-metadata-token" = $token}

$metadata=Invoke-RestMethod -Uri "http://169.254.169.254/latest/dynamic/instance-identity/document" -Headers @{"X-aws-ec2-metadata-token" = $token}

$Region = $metadata.region
Write-Host  "Retrieved REGION from AWS API ($Region)"

$InstanceId = $metadata.instanceId
Write-Host  "Retrieved InstanceId from AWS API ($InstanceId)"

$tags=aws ec2 describe-tags --region "$Region" --filters "Name=resource-id,Values=$InstanceId" | ConvertFrom-Json
Write-Host  "Retrieved tags from AWS API"

$project=$tags.Tags.where( {$_.Key -eq 'spb:project'}).value
Write-Host  "Retrieved spb:project tag - ($project)"

$environment=$tags.Tags.where( {$_.Key -eq 'spb:environment'}).value
Write-Host  "Retrieved spb:environment tag - ($environment)"

$cloudwatch_enabled=$tags.Tags.where( {$_.Key -eq 'spb:cloudwatch-enabled'}).value
Write-Host  "Retrieved spb:cloudwatch-enabled tag - ($cloudwatch_enabled)"

if ($cloudwatch_enabled -eq "true")
{
    Write-Host  "Enabling CloudWatch Agent"
    $spb_runner=$tags.Tags.where( {$_.Key -eq 'spb:runner'}).value
    Write-Host  "Retrieved spb:runner tag - ($spb_runner)"

    $CloudwatchConfigParameterName="/spb/$project/$environment/runners/$spb_runner/cloudwatch-config"

    & 'C:\Program Files\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1' -a fetch-config -m ec2 -s -c "ssm:$CloudwatchConfigParameterName"
}

$spb_start_github_runner=$tags.Tags.where( {$_.Key -eq 'spb:start-github-runner'}).value
Write-Host  "Retrieved spb:start-github-runner tag - ($spb_start_github_runner)"
if ($spb_start_github_runner -ne "true")
{
    Write-Host  "Not starting the GitHub Runner. Exiting."
    Exit 0
}

## Configure the runner

Write-Host "Get GH Runner config from AWS SSM"
$RunnerConfigParameterName="/spb/$project/$environment/config/$InstanceId"
$config = $null
$i = 0
do {
    $config = (aws ssm get-parameter --name "$RunnerConfigParameterName" --with-decryption --region $Region  --query "Parameter.{value:Value}" | ConvertFrom-Json | select -exp value | ConvertFrom-Json)
    Write-Host "Waiting for GH Runner config to become available in AWS SSM ($i/180)"
    Start-Sleep 1
    $i++
} while (($null -eq $config) -and ($i -lt 180))


if ($config -eq $null)
{
    Write-Host "Failed to get GH Runner config"
    aws ec2 terminate-instances --instance-ids $InstanceId --region $Region
} else {
  Write-Host "Delete GH Runner token from AWS SSM"
  aws ssm delete-parameter --name "$RunnerConfigParameterName" --region $Region
}

$runner_config = $config.runner_config

# Disable User Access Control (UAC)
# TODO investigate if this is needed or if its overkill - https://github.com/philips-labs/terraform-aws-github-runner/issues/1505
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -Value 0 -Force
Write-Host "Disabled User Access Control (UAC)"

Set-Location -Path c:\actions-runner -PassThru
$configCmd = "$pwd\config.cmd --unattended --name $InstanceId --work `"_work`" $runner_config"

Write-Host "Configure GH Runner"
Invoke-Expression $configCmd

$NotificationUrl = $config.notification_url
$NotificationUUID = $config.notification_uuid

$notify_runner_started_contents = @"
Write-Host "Notifying that the runner $InstanceId is working..."
`$RequestParameters = @{
    Uri     = '$NotificationUrl'
    Method  = 'POST'
    Body    = ''
    Headers = @{
        "Content-Type" = "application/json"
        "x-gh-runner-event" = "runner-started"
        "x-gh-runner-name" = "$InstanceId"
        "x-gh-runner-token" = "$NotificationUUID"
    }
}

Invoke-WebRequest `@RequestParameters
"@
Set-Content -Path "c:\Notify-Runner-Started.ps1" -Value $notify_runner_started_contents -Force

$notify_runner_completed_contents = @"
Write-Host "Notifying that the runner $InstanceId finished working..."
`$RequestParameters = @{
    Uri     = '$NotificationUrl'
    Method  = 'POST'
    Body    = ''
    Headers = @{
        "Content-Type" = "application/json"
        "x-gh-runner-event" = "runner-completed"
        "x-gh-runner-name" = "$InstanceId"
        "x-gh-runner-token" = "$NotificationUUID"
    }
}

Invoke-WebRequest `@RequestParameters
"@
Set-Content -Path "c:\Notify-Runner-Completed.ps1" -Value $notify_runner_completed_contents -Force

$jsonBody = @(
    @{
        group='Runner Image'
        details="AMI id: $ami_id"
    }
)
ConvertTo-Json -InputObject $jsonBody | Set-Content -Path "$pwd\.setup_info"

Write-Host "Starting the GitHub Actions Runner"
Write-Host "Starting runner after $(((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).tostring("hh':'mm':'ss''"))"

$env:ACTIONS_RUNNER_HOOK_JOB_STARTED="c:\Notify-Runner-Started.ps1"
$env:ACTIONS_RUNNER_HOOK_JOB_COMPLETED="c:\Notify-Runner-Completed.ps1"
$env:AGENT_TOOLSDIRECTORY="c:\hostedtoolcache"
$env:RUNNER_TOOL_CACHE="c:\hostedtoolcache"
Invoke-Expression "$pwd\run.cmd"
Start-Sleep 5
$TerminateCommand = "aws ec2 terminate-instances --instance-ids $InstanceId --region $Region"
Write-Host "Terminating instance"
Start-Sleep 1
Stop-Transcript
Start-Sleep 5
Invoke-Expression $TerminateCommand
