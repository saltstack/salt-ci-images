# -*- coding: utf-8 -*-
'''
tasks.cleanup
~~~~~~~~~~~

Cleanup Tasks
'''
# Import Python Libs
import os
import sys
import pprint
import textwrap
import time
from operator import itemgetter

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

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMESTAMP_UI = ' -timestamp-ui' if 'DRONE' in os.environ else ''
PACKER_TMP_DIR = os.path.join(REPO_ROOT, '.tmp', '{}')


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
def cleanup_aws(ctx,
                distro=None,
                distro_version=None,
                region='us-west-2',
                name_filter=None,
                staging=False,
                promoted=False,
                num_to_keep=1,
                dry_run=False,
                assume_yes=False):

    if HAS_BOTO is False:
        exit_invoke(1, 'Please install boto3: \'pip install -r {}\''.format(os.path.join(REPO_ROOT, 'requirements', 'base.txt')))

    if HAS_BLESSINGS is False:
        exit_invoke(1, 'Please install blessings: \'pip install -r {}\''.format(os.path.join(REPO_ROOT, 'requirements', 'base.txt')))

    if not distro and not name_filter:
        exit_invoke(1, 'You need to provide at least either \'distro\' or \'name_filter\'')

    if name_filter is None:
        if distro is None:
            exit_invoke(1, 'You need to provide at least either \'distro\' or \'name_filter\'')
        name_filter = 'saltstack/ci'
        if staging is True:
            name_filter += '-staging'
        name_filter += '/{}'.format(distro.lower())
        if distro_version:
            name_filter += '/{}'.format(distro_version)

    if not name_filter.endswith('*'):
        name_filter += '*'

    client = boto3.client('ec2', region_name=region)
    filters = [
        {
            'Name': 'name',
            'Values': [
                name_filter
            ]
        },
        {
            'Name': 'state',
            'Values': [
                'available'
            ]
        },
        {
            'Name': 'tag:Promoted',
            'Values': [
                '1' if promoted else '0'
            ]
        }
    ]
    response = client.describe_images(Filters=filters)
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        exit_invoke(1, 'Failed to get images. Full response:\n{}'.format(pprint.pformat(response)))

    if not response['Images']:
        if num_to_keep == 0:
            exit_invoke(0, 'No images were returned. Full response:\n{}', pprint.pformat(response))
        else:
            exit_invoke(2, 'No images were returned. Full response:\n{}', pprint.pformat(response))

    images_listing = sorted(response['Images'], key=itemgetter('Name'))
    if num_to_keep:
        images_to_delete = images_listing[:num_to_keep * -1]
    else:
        images_to_delete = images_listing

    if not images_to_delete:
        exit_invoke(
            0, 'Not going to delete {} image(s) that should be kept'.format(
                min(len(images_listing), num_to_keep)
            )
        )

    exitcode = 0

    ec2 = boto3.resource('ec2', region_name=region)
    for image_details in images_to_delete:
        image = ec2.Image(image_details['ImageId'])
        warn('Unregistering {}', image.id)
        info('Details:\n{}', textwrap.indent(pprint.pformat(image_details), 3 * ' '))
        block_devices = image.block_device_mappings
        try:
            if assume_yes is False:
                if terminal is not None:
                    answer = input(terminal.bold(terminal.yellow('Proceed? [N/y]')) + ' ')
                else:
                    answer = input('Proceed? [N/y] ')
                if not answer or not answer.lower().startswith('y'):
                    exit_invoke(0, 'Not proceeding.')
            response = image.deregister(DryRun=dry_run)
        except botocore.exceptions.ClientError as exc:
            if 'DryRunOperation' not in str(exc):
                error(exc)
                exitcode = 1
            else:
                warn(exc)
        time.sleep(10)
        for block_device in block_devices:
            if 'VirtualName' in block_device:
                # Just ignore virtual devices
                continue
            if 'Ebs' not in block_device:
                warn('Skipping non EBS block device with details:\n{}', pprint.pformat(block_device), 5 * ' ')
                continue
            snapshot_id = block_device['Ebs']['SnapshotId']
            warn('  Deleting snapshot {} of {}', snapshot_id, image.id)
            info('  Details:\n{}', textwrap.indent(pprint.pformat(block_device), 5 * ' '))
            try:
                if assume_yes is False:
                    if terminal is not None:
                        answer = input(terminal.bold(terminal.yellow('Proceed? [N/y]')) + ' ')
                    else:
                        answer = input('Proceed? [N/y] ')
                    if not answer or not answer.lower().startswith('y'):
                        exit_invoke(0, 'Not proceeding.')
                response = client.delete_snapshot(SnapshotId=snapshot_id, DryRun=dry_run)
            except botocore.exceptions.ClientError as exc:
                if 'DryRunOperation' not in str(exc):
                    error(exc)
                    exitcode = 1
                else:
                    warn(exc)

    exit_invoke(exitcode)
