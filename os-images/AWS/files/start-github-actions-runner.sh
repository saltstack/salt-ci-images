#!/usr/bin/env bash

# Disable debug output explicitly
set +x

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

chown -R "${RUN_AS}" /opt/actions-runner

RUNNER_CONFIG=$(echo "$CONFIG" | jq -r .runner_config)
echo "Configure GH Runner as user ${RUN_AS}"
sudo -i -u "${RUN_AS}" -- /opt/actions-runner/config.sh --unattended --name "$INSTANCE_ID" --work "_work" $${RUNNER_CONFIG}

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
echo "Starting the runner as user ${RUN_AS}"
cat >/opt/actions-runner/real-start-runner-service.sh <<-EOF
    echo "Starting the runner in ephemeral mode"
    # Unset any AWS_ prefixed environment variables
    for name in \$(printenv | grep AWS_ | cut -f 1 -d =); do
        unset -v \$name
    done
    export PATH=~/.local/bin:\$PATH
    export ACTIONS_RUNNER_HOOK_JOB_STARTED=/opt/actions-runner/notify-runner-started.sh
    export ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/opt/actions-runner/notify-runner-completed.sh
    /opt/actions-runner/run.sh
EOF
chmod 755 /opt/actions-runner/real-start-runner-service.sh

cat >/opt/actions-runner/start-runner-service.sh <<-EOF
    echo "Starting the runner in ephemeral mode"
    sudo -i -u "${RUN_AS}" -- bash /opt/actions-runner/real-start-runner-service.sh
    echo "Runner has finished"
    echo "Terminating instance"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION"
EOF
chmod 755 /opt/actions-runner/start-runner-service.sh

chown -R "${RUN_AS}" /opt/actions-runner

# Starting the runner via a own process to ensure this process terminates
nohup /opt/actions-runner/start-runner-service.sh &
