#!/usr/bin/env bash

# Disable debug output explicitly
set +x

# Define our logging file and pipe paths
LOGFILE="/var/log/runner-startup.log"
LOGPIPE="/tmp/start-github-actions-runner.logpipe"
# Ensure no residual pipe exists
rm "$LOGPIPE" 2>/dev/null

# Create our logging pipe
# On FreeBSD we have to use mkfifo instead of mknod
if ! (mknod "$LOGPIPE" p >/dev/null 2>&1 || mkfifo "$LOGPIPE" >/dev/null 2>&1); then
    echo "Failed to create the named pipe required to log"
    exit 1
fi

# What ever is written to the logpipe gets written to the logfile
tee < "$LOGPIPE" "$LOGFILE" &

# Close STDOUT, reopen it directing it to the logpipe
exec 1>&-
exec 1>"$LOGPIPE"
# Close STDERR, reopen it directing it to the logpipe
exec 2>&-
exec 2>"$LOGPIPE"

## Retrieve instance metadata
echo "Retrieving TOKEN from AWS API"
TOKEN=$(curl -sS -f -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 180")

SPB_DEBUG=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:debug)
echo "Retrieved spb:debug - ($SPB_DEBUG)"
if [ "$SPB_DEBUG" = "true" ]; then
    # Enable debug output
    set -x
fi

AMI_ID=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/ami-id)

REGION=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
echo "Retrieved REGION from AWS API ($REGION)"

INSTANCE_ID=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/instance-id)
echo "Retrieved INSTANCE_ID from AWS API ($INSTANCE_ID)"

SPB_START_GITHUB_RUNNER=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:start-github-runner)
echo "Retrieved spb:start_github_runner tag - ($SPB_START_GITHUB_RUNNER)"

if [ "$SPB_START_GITHUB_RUNNER" != "true" ]; then
    echo "Not starting the GitHub Runner. Exiting."
    exit 0
fi

PROJECT=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:project)
echo "Retrieved spb:project tag - ($PROJECT)"

ENVIRONMENT=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:environment)
echo "Retrieved spb:environment tag - ($ENVIRONMENT)"

ENABLE_CLOUDWATCH_AGENT=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:cloudwatch-enabled)
echo "Retrieved spb:cloudwatch-enabled - ($ENABLE_CLOUDWATCH_AGENT)"

if [ "$ENABLE_CLOUDWATCH_AGENT" = "true" ]; then
    echo "Cloudwatch is enabled"
    SPB_RUNNER=$(curl -sS -f -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/tags/instance/spb:runner)
    echo "Retrieved spb:runner - ($SPB_RUNNER)"
    CLOUDWATCH_CONFIG_PARAMETER_NAME="/spb/$PROJECT/$ENVIRONMENT/runners/$SPB_RUNNER/cloudwatch-config"
    amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c "ssm:$CLOUDWATCH_CONFIG_PARAMETER_NAME"
fi

## Configure the runner
echo "Get GH Runner config from AWS SSM"
RUNNER_CONFIG_PARAMETER_NAME="/spb/$PROJECT/$ENVIRONMENT/config/$INSTANCE_ID"
CONFIG=$(aws ssm get-parameter --name "$RUNNER_CONFIG_PARAMETER_NAME" --with-decryption --region "$REGION" 2>/dev/null | jq -r ".Parameter | .Value")

RETRY=1
while [ -z "$CONFIG" ]; do
    echo "Waiting for GH Runner config to become available in AWS SSM"
    sleep 1
    CONFIG=$(aws ssm get-parameter --name "$RUNNER_CONFIG_PARAMETER_NAME" --with-decryption --region "$REGION" 2>/dev/null | jq -r ".Parameter | .Value")
    (( RETRY++ ))
    if [ $RETRY -gt 180 ]; then
        echo "Failed to get the required runner configuration after $RETRY seconds."
        echo "Terminating instance"
        aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
        exit 1
    fi
done

NOTIFICATION_URL=$(echo "$CONFIG" | jq -r .notification_url)
NOTIFICATION_UUID=$(echo "$CONFIG" | jq -r .notification_uuid)

cat >/opt/actions-runner/notify-runner-started.sh <<-EOF
echo "Notifying that the runner $INSTANCE_ID is working..."
RUNNER_NOTIFICATION_URL=$NOTIFICATION_URL
curl -f -s -H "Content-Type: application/json" -H "x-gh-runner-event: runner-started" -H "x-gh-runner-name: $INSTANCE_ID" -H "x-gh-runner-token: $NOTIFICATION_UUID" -X POST \$RUNNER_NOTIFICATION_URL
EOF
chmod 755 /opt/actions-runner/notify-runner-started.sh

cat >/opt/actions-runner/notify-runner-completed.sh <<-EOF
echo "Notifying that the runner $INSTANCE_ID finished working..."
RUNNER_NOTIFICATION_URL=$NOTIFICATION_URL
curl -f -s -H "Content-Type: application/json" -H "x-gh-runner-event: runner-completed" -H "x-gh-runner-name: $INSTANCE_ID" -H "x-gh-runner-token: $NOTIFICATION_UUID" -X POST \$RUNNER_NOTIFICATION_URL
EOF
chmod 755 /opt/actions-runner/notify-runner-completed.sh

if [ "$SPB_DEBUG" != "true" ]; then
    echo "Delete GH Runner secrets from AWS SSM"
    aws ssm delete-parameter --name "$RUNNER_CONFIG_PARAMETER_NAME" --region "$REGION"
fi

if [ "$(cat /etc/os-release | grep ID_LIKE= | grep rhel)" != "" ] && [ "$(cat /etc/os-release | grep -E ^VERSION= | grep '="9')" != "" ]; then
  # CentOS Stream 9 uses OpenSSL 3 and DotNet doesn't like it, yet
  # This is a workaround since SHA1 is now know not to be secure
  update-crypto-policies --set DEFAULT:SHA1
fi

chown -R {{ actions_runner_account }}:{{ actions_runner_account }} /opt/actions-runner

RUNNER_CONFIG=$(echo "$CONFIG" | jq -r .runner_config)
echo "Configure GH Runner as user {{ actions_runner_account }}"
sudo -i -u "{{ actions_runner_account }}" -- /opt/actions-runner/config.sh --unattended --name "$INSTANCE_ID" --work "_work" ${RUNNER_CONFIG}

INFO_ARCH=$(uname -p)
INFO_OS=$( ( lsb_release -ds || cat /etc/*release || uname -om ) 2>/dev/null | head -n1 | cut -d "=" -f2- | tr -d '"')
tee /opt/actions-runner/.setup_info <<EOL
[
  {
    "group": "Operating System",
    "detail": "Distribution: $INFO_OS\nArchitecture: $INFO_ARCH"
  },
  {
    "group": "Runner Image",
    "detail": "AMI id: $AMI_ID\nSalt Golden Image: true"
  }
]
EOL
## Start the runner
echo "Starting runner after $(awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}' /proc/uptime)"
echo "Starting the runner as user {{ actions_runner_account }}"

cat >/opt/actions-runner/start-runner-service.sh <<-EOF
#!/usr/bin/env bash

__trap_exit() {
    echo "Terminating instance"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
}
trap "__trap_exit" INT ABRT QUIT TERM

cd /opt/actions-runner
echo "Starting the runner in ephemeral mode"

export PATH=~/.local/bin:\$PATH
export ACTIONS_RUNNER_HOOK_JOB_STARTED=/opt/actions-runner/notify-runner-started.sh
export ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/opt/actions-runner/notify-runner-completed.sh
export AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
export RUNNER_TOOL_CACHE=/opt/hostedtoolcache
/opt/actions-runner/bin/runsvc.sh
echo "Runner has finished"
echo "Terminating instance"
aws ec2 terminate-instancts --instance-ids "$INSTANCE_ID" --region "$REGION"
EOF
chmod 755 /opt/actions-runner/start-runner-service.sh

chown -R {{ actions_runner_account }}:{{ actions_runner_account }} /opt/actions-runner


SVC_NAME=github-actions-runner
CONFIG_PATH=/opt/actions-runner/.service
UNIT_PATH=/etc/systemd/system/${SVC_NAME}.service
command -v getenforce > /dev/null
if [ $? -eq 0 ]
then
    selinuxEnabled=$(getenforce)
    if [[ $selinuxEnabled == "Enforcing" ]]
    then
        # SELinux is enabled, we will need to Restore SELinux Context for the service file
        restorecon -r -v "${UNIT_PATH}" || failed "failed to restore SELinux context on ${UNIT_PATH}"
    fi
fi
systemctl daemon-reload || failed "failed to reload daemons"
echo "${SVC_NAME}" > ${CONFIG_PATH} || failed "failed to create ${CONFIG_PATH} file"
chown {{ actions_runner_account }}:{{ actions_runner_account }} ${CONFIG_PATH} || failed "failed to set permission for ${CONFIG_PATH}"

function service_exists() {
    if [ -f "${UNIT_PATH}" ]; then
        return 0
    else
        return 1
    fi
}

function status()
{
    if service_exists; then
        echo
        echo "${UNIT_PATH}"
    else
        echo
        echo "not installed"
        echo
        exit 1
    fi

    systemctl --no-pager status ${SVC_NAME}
}

function start()
{
    systemctl start ${SVC_NAME} || failed "failed to start ${SVC_NAME}"
    status
}

start
