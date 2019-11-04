# -*- coding: utf-8 -*-
'''
tasks.build
~~~~~~~~~~~

Bulid Tasks
'''
# Import Python Libs
import os
import sys

# Import invoke libs
from invoke import task

# Additional libs
from shutil import which

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMESTAMP_UI = ' -timestamp-ui' if 'DRONE' in os.environ else ''
PACKER_TMP_DIR = os.path.join(REPO_ROOT, '.tmp', '{}')


def _binary_install_check(binary):
    '''Checks if the given binary is installed. Otherwise we exit with return code 10.'''
    if not which(binary):
        exit_invoke(10, "Couldn't find {}. Please install to proceed.", binary)


def exit_invoke(exitcode, message=None, *args, **kwargs):
    if message is not None:
        sys.stderr.write(message.format(*args, **kwargs).strip() + '\n')
        sys.stderr.flush()
    sys.exit(exitcode)


@task
def build_aws(ctx,
              distro,
              distro_version=None,
              region='us-west-2',
              salt_branch='master',
              debug=False,
              staging=False,
              validate=False,
              salt_pr=None):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join('os-images', 'AWS', distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, 'The directory {} does not exist. Are you passing the right OS?', distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += '-{}'.format(distro_version)

    template_variations = [
        os.path.join(distro_dir, '{}.json'.format(distro_slug)),
        os.path.join(distro_dir, '{}.json'.format(distro))
    ]
    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build template. Tried: {}',
                    ', '.join(template_variations))

    vars_variations = [
        os.path.join(distro_dir, '{}-{}.json'.format(distro_slug, region)),
        os.path.join(distro_dir, '{}-{}.json'.format(distro, region))
    ]
    for variation in vars_variations:
        if os.path.exists(variation):
            build_vars = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build vars file. Tried: {}',
                    ', '.join(vars_variations))

    packer_tmp_dir = PACKER_TMP_DIR.format(distro_slug)
    if not os.path.exists(packer_tmp_dir):
        os.makedirs(packer_tmp_dir)
    os.chmod(os.path.dirname(packer_tmp_dir), 0o755)
    os.chmod(packer_tmp_dir, 0o755)
    if distro_slug.startswith('windows'):
        scripts_path = os.path.join(packer_tmp_dir, 'scripts')
        if not os.path.exists(scripts_path):
            os.makedirs(scripts_path)
        os.chmod(scripts_path, 0o755)
        with open(os.path.join(scripts_path, 'Install-Git.ps1'), 'w') as wfh:
            wfh.write('')
    for name in ('states', 'win_states', 'pillar', 'conf'):
        path = os.path.join(packer_tmp_dir, salt_branch, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    cmd = 'packer'
    _binary_install_check(cmd)
    if validate is True:
        cmd += ' validate'
    else:
        cmd += ' build'
        if debug is True:
            cmd += ' -debug -on-error=ask'
        cmd += TIMESTAMP_UI
    cmd += ' -var-file={}'.format(build_vars)
    if staging is True:
        cmd += ' -var build_type=ci-staging'
    if salt_pr:
        cmd += ' -var salt_pr={}'.format(salt_pr)
    cmd += ' -var distro_slug={} -var salt_branch={} {}'.format(distro_slug,
                                                                salt_branch,
                                                                build_template)
    ctx.run(cmd, echo=True, env={'PACKER_TMP_DIR': packer_tmp_dir})


@task
def build_docker(ctx,
                 distro,
                 distro_version=None,
                 salt_branch='master',
                 debug=False,
                 staging=False,
                 validate=False):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join('os-images', 'Docker', distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, 'The directory {} does not exist. Are you passing the right OS?', distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += '-{}'.format(distro_version)

    template_variations = [
        os.path.join(distro_dir, '{}.json'.format(distro_slug)),
        os.path.join(distro_dir, '{}.json'.format(distro))
    ]
    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build template. Tried: {}',
                    ', '.join(template_variations))

    vars_variations = [
        os.path.join(distro_dir, '{}-vars.json'.format(distro_slug)),
        os.path.join(distro_dir, '{}-vars.json'.format(distro))
    ]
    for variation in vars_variations:
        if os.path.exists(variation):
            build_vars = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build vars file. Tried: {}',
                    ', '.join(vars_variations))

    packer_tmp_dir = PACKER_TMP_DIR.format(distro_slug)
    if not os.path.exists(packer_tmp_dir):
        os.makedirs(packer_tmp_dir)
    os.chmod(os.path.dirname(packer_tmp_dir), 0o755)
    os.chmod(packer_tmp_dir, 0o755)
    if distro_slug.startswith('windows'):
        scripts_path = os.path.join(packer_tmp_dir, 'scripts')
        if not os.path.exists(scripts_path):
            os.makedirs(scripts_path)
        os.chmod(scripts_path, 0o755)
        with open(os.path.join(scripts_path, 'Install-Git.ps1'), 'w') as wfh:
            wfh.write('')
    for name in ('states', 'win_states', 'pillar', 'conf'):
        path = os.path.join(packer_tmp_dir, salt_branch, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    cmd = 'packer'
    _binary_install_check(cmd)
    if validate is True:
        cmd += ' validate'
    else:
        cmd += ' build'
        if debug is True:
            cmd += ' -debug -on-error=ask'
        cmd += TIMESTAMP_UI
    cmd += ' -var-file={}'.format(build_vars)
    if staging is True:
        cmd += ' -var build_type=ci-staging'
    cmd += ' -var distro_slug={} -var salt_branch={} {}'.format(distro_slug,
                                                                salt_branch,
                                                                build_template)
    ctx.run(cmd, echo=True, env={'PACKER_TMP_DIR': packer_tmp_dir})
