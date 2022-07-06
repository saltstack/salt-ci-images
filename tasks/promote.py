# -*- coding: utf-8 -*-
'''
tasks.promote
~~~~~~~~~~~~~

Promote an AWS AMI
'''

# Import Python Libs
import os
import sys

# Import invoke libs
from invoke import task

# Import 3rd-party libs
try:
    import boto3
    HAS_BOTO = True
except ImportError:
    HAS_BOTO = False
if HAS_BOTO:
    import botocore.exceptions
try:
    from blessings import Terminal
    terminal = Terminal()
    HAS_BLESSINGS = True
except ImportError:
    terminal = None
    HAS_BLESSINGS = False


def exit_invoke(exitcode, message=None, *args, **kwargs):
    if message is not None:
        if exitcode > 0:
            warn(message, *args, **kwargs)
        else:
            info(message, *args, **kwargs)
    sys.exit(exitcode)


def info(message, *args, **kwargs):
    if not isinstance(message, str):
        message = str(message)
    message = message.format(*args, **kwargs)
    if terminal:
        message = terminal.bold(terminal.green(message))
    write_message(message)


def warn(message, *args, **kwargs):
    if not isinstance(message, str):
        message = str(message)
    message = message.format(*args, **kwargs)
    if terminal:
        message = terminal.bold(terminal.yellow(message))
    write_message(message)


def error(message, *args, **kwargs):
    if not isinstance(message, str):
        message = str(message)
    message = message.format(*args, **kwargs)
    if terminal:
        message = terminal.bold(terminal.red(message))
    write_message(message)


def write_message(message):
    sys.stderr.write(message)
    if not message.endswith('\n'):
        sys.stderr.write('\n')
    sys.stderr.flush()


@task
def promote_ami(ctx,
                image_id,
                region='us-west-2',
                dry_run=False,
                assume_yes=False):

    if HAS_BOTO is False:
        exit_invoke(1, 'Please install boto3: \'pip install -r {}\''.format(os.path.join(REPO_ROOT, 'requirements', 'base.txt')))

    if HAS_BLESSINGS is False:
        exit_invoke(1, 'Please install blessings: \'pip install -r {}\''.format(os.path.join(REPO_ROOT, 'requirements', 'base.txt')))

    if not image_id:
        exit_invoke(1, 'You need to provide --image-id')

    ec2 = boto3.resource('ec2', region_name=region)

    info('Promoting AMI {}', image_id)

    try:
        ami = ec2.Image(image_id)
        # Acccess an image attribute to ensure its a valid AMI
        ami.tags
    except botocore.exceptions.ClientError as exc:
        exit_invoke(1, exc)

    exitcode = 0
    promoted_tag_found = False
    for tag in ami.tags:
        if tag['Key'] == 'Promoted':
            promoted_tag_found = True
            if tag['Value'] == '1':
                exit_invoke(1, 'The {} AMI is already promoted', image_id)
            tag['Value'] = '1'
        if tag['Key'] == 'Name':
            if not tag['Value'].startswith('PROMOTED //'):
                tag['Value'] = 'PROMOTED // {}'.format(tag['Value'])

    if promoted_tag_found is False:
        ami.tags.append({'Key': 'Promoted', 'Value': '1'})

    if assume_yes is False:
        if terminal is not None:
            answer = input(terminal.bold(terminal.yellow('Proceed? [N/y]')) + ' ')
        else:
            answer = input('Proceed? [N/y] ')
        if not answer or not answer.lower().startswith('y'):
            exit_invoke(0, 'Not proceeding.')

    try:
        ami.create_tags(Tags=ami.tags, DryRun=dry_run)
    except botocore.exceptions.ClientError as exc:
        if 'DryRunOperation' not in str(exc):
            error(exc)
            exitcode = 1
        else:
            warn(exc)

    try:
        if not ami.description.startswith('PROMOTED '):
            ami.modify_attribute(Attribute='description', Value='PROMOTED ' + ami.description, DryRun=dry_run)
    except botocore.exceptions.ClientError as exc:
        if 'DryRunOperation' not in str(exc):
            error(exc)
            exitcode = 1
        else:
            warn(exc)

    exit_invoke(exitcode)

