# -*- coding: utf-8 -*-
'''
tasks.build
~~~~~~~~~~~

Bulid Tasks
'''
# Import Python Libs
import os
import sys
import json
import time
import pprint
import threading

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
              debug=False,
              staging=False,
              validate=False,
              salt_pr=None,
              distro_arch=None):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join('os-images', 'AWS', distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, 'The directory {} does not exist. Are you passing the right OS?', distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += '-{}'.format(distro_version)
    if distro_arch:
        distro_slug += '-{}'.format(distro_arch)

    template_variations = [
        os.path.join(distro_dir, '{}.json'.format(distro_slug))
    ]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_arch)))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_version)))
    template_variations.append(os.path.join(distro_dir, '{}.json'.format(distro)))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build template. Tried: {}',
                    ', '.join(template_variations))

    vars_variations = [
        os.path.join(distro_dir, '{}-{}.json'.format(distro_slug, region))
    ]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-{}.json'.format(distro, distro_arch, region)))
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-{}.json'.format(distro, distro_version, region)))
    vars_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, region)))

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
        path = os.path.join(packer_tmp_dir, name)
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
    else:
        cmd += ' -var build_type=ci'
    if salt_pr and salt_pr.lower() != "null":
        cmd += ' -var salt_pr={}'.format(salt_pr)
    cmd += ' -var distro_slug={} {}'.format(distro_slug, build_template)
    ctx.run(cmd, echo=True)


@task
def build_docker(ctx,
                 distro,
                 distro_version=None,
                 debug=False,
                 staging=False,
                 validate=False,
                 salt_pr=None,
                 distro_arch=None):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join('os-images', 'Docker', distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, 'The directory {} does not exist. Are you passing the right OS?', distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += '-{}'.format(distro_version)
    if distro_arch:
        distro_slug += '-{}'.format(distro_arch)

    template_variations = [
        os.path.join(distro_dir, '{}.json'.format(distro_slug))
    ]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_arch)))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_version)))
    template_variations.append(os.path.join(distro_dir, '{}.json'.format(distro)))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build template. Tried: {}',
                    ', '.join(template_variations))

    vars_variations = [
        os.path.join(distro_dir, '{}-vars.json'.format(distro_slug))
    ]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-vars.json'.format(distro, distro_arch)))
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-vars.json'.format(distro, distro_version)))
    vars_variations.append(os.path.join(distro_dir, '{}-vars.json'.format(distro)))

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
        path = os.path.join(packer_tmp_dir, name)
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
    else:
        cmd += ' -var build_type=ci'
    if salt_pr and salt_pr.lower() != "null":
        cmd += ' -var salt_pr={}'.format(salt_pr)
    cmd += ' -var distro_slug={} {}'.format(distro_slug, build_template)
    ctx.run(cmd, echo=True)

@task
def build_osx(ctx,
              distro_version,
              debug=False,
              staging=False,
              validate=False,
              salt_pr=None,
              force_download=False,
              distro_arch=None):
    distro = 'macos'
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join('os-images', 'MacStadium', distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, 'The directory {} does not exist. Are you passing the right OS?', distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += '-{}'.format(distro_version)
    if distro_arch:
        distro_slug += '-{}'.format(distro_arch)

    template_variations = [
        os.path.join(distro_dir, '{}.json'.format(distro_slug))
    ]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_arch)))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, '{}-{}.json'.format(distro, distro_version)))
    template_variations.append(os.path.join(distro_dir, '{}.json'.format(distro)))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(1, 'Could not find the distribution build template. Tried: {}',
                    ', '.join(template_variations))

    vars_variations = [
        os.path.join(distro_dir, '{}-vars.json'.format(distro_slug))
    ]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-vars.json'.format(distro, distro_arch)))
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, '{}-{}-vars.json'.format(distro, distro_version)))
    vars_variations.append(os.path.join(distro_dir, '{}-vars.json'.format(distro)))

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
    boxes_cache_dir = os.path.expanduser(os.path.join('~', '.local', 'cache', 'packer-vagrant-boxes'))
    if not os.path.exists(boxes_cache_dir):
        os.makedirs(boxes_cache_dir)
    os.chmod(boxes_cache_dir, 0o755)
    for name in ('states', 'pillar'):
        path = os.path.join(packer_tmp_dir, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    def get_url_headers(url):
        cmd = 'curl'
        _binary_install_check(cmd)
        cmd += ' -s --head {} | grep -e x-checksum'.format(url)
        output = ctx.run(cmd, echo=True)
        headers = {}
        for line in output.stdout.strip().splitlines():
            key, value = line.split(':')
            headers[key.strip()] = value.strip()
        return headers

    def get_content_length(url):
        cmd = 'curl'
        _binary_install_check(cmd)
        cmd += ' -s --head {} | grep -e content-length'.format(url)
        result = ctx.run(cmd, echo=True)
        output = result.stdout.strip()
        _, content_length = output.split(':')
        content_length = int(content_length.strip())
        return content_length

    def parallel_download_url(url, dest):

        def download_chunk(url, dest, start, end):
            cmd = 'curl -sS -L -o {} --range {}-{} {}'.format(dest, start, end, url)
            ctx.run(cmd, echo=True)

        threads = []
        content_length = get_content_length(url)
        chunks = 15
        chunk_size = content_length // chunks
        for chunk in range(chunks):
            start = 0
            if chunk:
                start = chunk * chunk_size + (1 * chunk)
            end = start + chunk_size
            if end > content_length:
                end = content_length
            part_dest = dest + '.part{}'.format(chunk)
            t = threading.Thread(target=download_chunk, args=(url, part_dest, start, end))
            threads.append(t)
            t.start()

        while threads:
            t = threads.pop(0)
            if not t.is_alive():
                t.join()
            else:
                threads.append(t)
            time.sleep(1)

        cmd = 'cat'
        for chunk in range(chunks):
            part_dest = dest + '.part{}'.format(chunk)
            cmd = 'cat {} >> {}'.format(part_dest, dest)
            if not chunk:
                cmd = cmd.replace('>>', '>')
            ctx.run(cmd, echo=True)
            os.unlink(part_dest)

    with open(build_vars) as rfh:
        _vars = json.load(rfh)
        source_box_name = _vars['source_box_name']

    source_box_dest = os.path.join(boxes_cache_dir, source_box_name + '.box')
    source_box_dest_headers = source_box_dest + '.headers'
    source_box_url = 'https://artifactory.saltstack.net/artifactory/vagrant-boxes/macos/{}.box'.format(source_box_name)
    if os.path.exists(source_box_dest):
        if force_download:
            os.unlink(source_box_dest)
            if os.path.exists(source_box_dest_headers):
                os.unlink(source_box_dest_headers)
        elif os.path.exists(source_box_dest_headers):
            # Let's see if the download we have is up to date
            cached_headers = json.loads(open(source_box_dest_headers).read().strip())
            headers = get_url_headers(source_box_url)
            if headers != cached_headers:
                print('Cached Headers:\n{}'.format(pprint.pformat(cached_headers)))
                print('Current Headers:\n{}'.format(pprint.pformat(headers)))
                print('Headers do not match. Re-downloading the image')
                os.unlink(source_box_dest)
                os.unlink(source_box_dest_headers)

    if not os.path.exists(source_box_dest):
        _binary_install_check('curl')
        parallel_download_url(source_box_url, source_box_dest)
        headers = get_url_headers(source_box_url)
        with open(source_box_dest_headers, 'w') as wfh:
            wfh.write(json.dumps(headers))

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
    else:
        cmd += ' -var build_type=ci'
    if salt_pr and salt_pr.lower() != "null":
        cmd += ' -var salt_pr={}'.format(salt_pr)
    cmd += ' -var boxes_cache_dir={}'.format(boxes_cache_dir)
    cmd += ' -var source_box_name={}'.format(source_box_name)
    cmd += ' -var distro_slug={} {}'.format(distro_slug, build_template)
    env = {}
    if 'ARTIFACTORY_URL' not in os.environ:
        env['ARTIFACTORY_URL'] = 'https://artifactory.saltstack.net/artifactory'

    ctx.run(cmd, echo=True, env=env)
