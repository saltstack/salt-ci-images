"""
Bulid Tasks.
"""
from __future__ import annotations

import json
import os
import pprint
import sys
import threading
import time
from datetime import datetime
from shutil import which

from invoke import task
from invoke.exceptions import UnexpectedExit

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIMESTAMP_UI = " -timestamp-ui" if "CI" in os.environ else ""
PACKER_TMP_DIR = os.path.join(REPO_ROOT, ".tmp", "{}")

DISTRO_DISPLAY_NAMES = {
    "almalinux": "AlmaLinux",
    "amazon": "Amazon",
    "arch": "Arch",
    "centos": "CentOS",
    "centos-stream": "CentOS Stream",
    "opensuse-tumbleweed": "Opensuse Tumbleweed",
    "oraclelinux": "Oracle Linux",
    "freebsd": "FreeBSD",
    "openbsd": "OpenBSD",
}


class BuildFailed(Exception):
    """
    Exception raised when a box build fails.
    """


def _binary_install_check(binary):
    """Checks if the given binary is installed. Otherwise we exit with return code 10."""
    if not which(binary):
        exit_invoke(10, "Couldn't find {}. Please install to proceed.", binary)


def exit_invoke(exitcode, message=None, *args, **kwargs):
    if message is not None:
        sys.stderr.write(message.format(*args, **kwargs).strip() + "\n")
        sys.stderr.flush()
    sys.exit(exitcode)


@task
def build_aws(
    ctx,
    distro,
    distro_version=None,
    region="us-west-2",
    debug=False,
    staging=False,
    validate=False,
    salt_pr=None,
    distro_arch=None,
):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join("os-images", "AWS", distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, "The directory {} does not exist. Are you passing the right OS?", distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += f"-{distro_version}"
    if distro_arch:
        distro_slug += f"-{distro_arch}"

    template_variations = [
        os.path.join(distro_dir, f"{distro_slug}.json"),
        os.path.join(distro_dir, f"{distro_slug}.pkr.hcl"),
    ]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}.json"))
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}.pkr.hcl"))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}.json"))
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}.pkr.hcl"))
    template_variations.append(os.path.join(distro_dir, f"{distro}.json"))
    template_variations.append(os.path.join(distro_dir, f"{distro}.pkr.hcl"))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build template.\nTried:\n{}",
            "\n".join(f" - {tv}" for tv in template_variations),
        )

    vars_variations = [
        os.path.join(distro_dir, f"{distro_slug}-{region}.json"),
        os.path.join(distro_dir, f"{distro_slug}-{region}.pkrvars.hcl"),
    ]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}-{region}.json"))
        vars_variations.append(
            os.path.join(distro_dir, f"{distro}-{distro_arch}-{region}.pkrvars.hcl")
        )
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}-{region}.json"))
        vars_variations.append(
            os.path.join(distro_dir, f"{distro}-{distro_version}-{region}.pkrvars.hcl")
        )
    vars_variations.append(os.path.join(distro_dir, f"{distro}-{region}.json"))
    vars_variations.append(os.path.join(distro_dir, f"{distro}-{region}.pkrvars.hcl"))

    for variation in vars_variations:
        if os.path.exists(variation):
            build_vars = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build vars file.\nTried:\n{}",
            "\n".join(f" - {vv}" for vv in vars_variations),
        )

    common_variables_path = os.path.join(distro_dir, "variables.pkr.hcl")

    packer_tmp_dir = PACKER_TMP_DIR.format(distro_slug)
    if not os.path.exists(packer_tmp_dir):
        os.makedirs(packer_tmp_dir)
    os.chmod(os.path.dirname(packer_tmp_dir), 0o755)
    os.chmod(packer_tmp_dir, 0o755)
    if distro_slug.startswith("windows"):
        scripts_path = os.path.join(packer_tmp_dir, "scripts")
        if not os.path.exists(scripts_path):
            os.makedirs(scripts_path)
        os.chmod(scripts_path, 0o755)
        with open(os.path.join(scripts_path, "Install-Git.ps1"), "w") as wfh:
            wfh.write("")
    for name in ("states", "win_states", "pillar", "conf"):
        path = os.path.join(packer_tmp_dir, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    cmd = "packer"
    _binary_install_check(cmd)
    if validate is True:
        cmd += " validate"
    else:
        cmd += " build"
        if debug is True:
            cmd += " -debug -on-error=ask"
        cmd += TIMESTAMP_UI
    if os.path.exists(common_variables_path):
        cmd += f" -var-file={common_variables_path}"
    cmd += f" -var-file={build_vars}"
    if staging is True:
        cmd += " -var build_type=ci-staging"
    else:
        cmd += " -var build_type=ci"
    if salt_pr and salt_pr.lower() != "null":
        cmd += f" -var salt_pr={salt_pr}"
    cmd += f" -var distro_slug={distro_slug} {build_template}"
    ctx.run(cmd, echo=True)


@task
def build_osx(
    ctx,
    distro_version,
    debug=False,
    staging=False,
    validate=False,
    salt_pr=None,
    force_download=False,
    distro_arch=None,
):
    distro = "macos"
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join("os-images", "MacStadium", distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, "The directory {} does not exist. Are you passing the right OS?", distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += f"-{distro_version}"
    if distro_arch:
        distro_slug += f"-{distro_arch}"

    template_variations = [os.path.join(distro_dir, f"{distro_slug}.json")]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}.json"))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}.json"))
    template_variations.append(os.path.join(distro_dir, f"{distro}.json"))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build template. Tried: {}",
            ", ".join(template_variations),
        )

    vars_variations = [os.path.join(distro_dir, f"{distro_slug}-vars.json")]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}-vars.json"))
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}-vars.json"))
    vars_variations.append(os.path.join(distro_dir, f"{distro}-vars.json"))

    for variation in vars_variations:
        if os.path.exists(variation):
            build_vars = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build vars file. Tried: {}",
            ", ".join(vars_variations),
        )

    packer_tmp_dir = PACKER_TMP_DIR.format(distro_slug)
    if not os.path.exists(packer_tmp_dir):
        os.makedirs(packer_tmp_dir)
    os.chmod(os.path.dirname(packer_tmp_dir), 0o755)
    os.chmod(packer_tmp_dir, 0o755)
    boxes_cache_dir = os.path.expanduser(
        os.path.join("~", ".local", "cache", "packer-vagrant-boxes")
    )
    if not os.path.exists(boxes_cache_dir):
        os.makedirs(boxes_cache_dir)
    os.chmod(boxes_cache_dir, 0o755)
    for name in ("states", "pillar"):
        path = os.path.join(packer_tmp_dir, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    def get_url_headers(url):
        cmd = "curl"
        _binary_install_check(cmd)
        cmd += f" -s --head {url} | grep -e x-checksum"
        output = ctx.run(cmd, echo=True)
        headers = {}
        for line in output.stdout.strip().splitlines():
            key, value = line.split(":")
            headers[key.strip()] = value.strip()
        return headers

    def get_content_length(url):
        cmd = "curl"
        _binary_install_check(cmd)
        cmd += f" -s --head {url} | grep -e content-length"
        result = ctx.run(cmd, echo=True)
        output = result.stdout.strip()
        _, content_length = output.split(":")
        content_length = int(content_length.strip())
        return content_length

    def parallel_download_url(url, dest):
        def download_chunk(url, dest, start, end):
            cmd = f"curl -sS -L -o {dest} --range {start}-{end} {url}"
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
            part_dest = dest + f".part{chunk}"
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

        cmd = "cat"
        for chunk in range(chunks):
            part_dest = dest + f".part{chunk}"
            cmd = f"cat {part_dest} >> {dest}"
            if not chunk:
                cmd = cmd.replace(">>", ">")
            ctx.run(cmd, echo=True)
            os.unlink(part_dest)

    with open(build_vars) as rfh:
        _vars = json.load(rfh)
        source_box_name = _vars["source_box_name"]

    source_box_dest = os.path.join(boxes_cache_dir, source_box_name + ".box")
    source_box_dest_headers = source_box_dest + ".headers"
    source_box_url = (
        f"https://artifactory.saltstack.net/artifactory/vagrant-boxes/macos/{source_box_name}.box"
    )
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
                print(f"Cached Headers:\n{pprint.pformat(cached_headers)}")
                print(f"Current Headers:\n{pprint.pformat(headers)}")
                print("Headers do not match. Re-downloading the image")
                os.unlink(source_box_dest)
                os.unlink(source_box_dest_headers)

    if not os.path.exists(source_box_dest):
        _binary_install_check("curl")
        parallel_download_url(source_box_url, source_box_dest)
        headers = get_url_headers(source_box_url)
        with open(source_box_dest_headers, "w") as wfh:
            wfh.write(json.dumps(headers))

    cmd = "packer"
    _binary_install_check(cmd)
    if validate is True:
        cmd += " validate"
    else:
        cmd += " build"
        if debug is True:
            cmd += " -debug -on-error=ask"
        cmd += TIMESTAMP_UI
    cmd += f" -var-file={build_vars}"
    if staging is True:
        cmd += " -var build_type=ci-staging"
    else:
        cmd += " -var build_type=ci"
    if salt_pr and salt_pr.lower() != "null":
        cmd += f" -var salt_pr={salt_pr}"
    cmd += f" -var boxes_cache_dir={boxes_cache_dir}"
    cmd += f" -var source_box_name={source_box_name}"
    cmd += f" -var distro_slug={distro_slug} {build_template}"
    env = {}
    if "ARTIFACTORY_URL" not in os.environ:
        env["ARTIFACTORY_URL"] = "https://artifactory.saltstack.net/artifactory"

    ctx.run(cmd, echo=True, env=env)


@task
def build_vagrant(
    ctx,
    distro,
    distro_version=None,
    force=False,
    debug=False,
    staging=False,
    validate=False,
    salt_pr=None,
    distro_arch="amd64",
    init=False,
    pull=False,
    no_test=False,
    vagrantcloud_user="salt-project-ci",
    test_command="nox --version",
    test_command_expected_std="stderr",
):
    distro = distro.lower()
    ctx.cd(REPO_ROOT)
    distro_dir = os.path.join("os-images", "Vagrant", distro)
    if not os.path.exists(distro_dir):
        exit_invoke(1, "The directory {} does not exist. Are you passing the right OS?", distro_dir)

    distro_slug = distro
    if distro_version:
        distro_slug += f"-{distro_version}"
    if distro_arch:
        distro_slug += f"-{distro_arch}"

    output_box_name = f"{distro_slug.replace('-amd64', '')}"
    output_box_version = datetime.utcnow().strftime("%Y%m%d.%H%M")

    template_variations = [
        os.path.join(distro_dir, f"{distro_slug}.pkr.hcl"),
    ]
    if distro_arch:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}.pkr.hcl"))
    if distro_version:
        template_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}.pkr.hcl"))
    template_variations.append(os.path.join(distro_dir, f"{distro}.pkr.hcl"))

    for variation in template_variations:
        if os.path.exists(variation):
            build_template = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build template.\nTried:\n{}",
            "\n".join(f" - {tv}" for tv in template_variations),
        )

    vars_variations = [
        os.path.join(distro_dir, f"{distro_slug}.pkrvars.hcl"),
    ]
    if distro_arch:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_arch}.pkrvars.hcl"))
    if distro_version:
        vars_variations.append(os.path.join(distro_dir, f"{distro}-{distro_version}.pkrvars.hcl"))
    vars_variations.append(os.path.join(distro_dir, f"{distro}.pkrvars.hcl"))

    for variation in vars_variations:
        if os.path.exists(variation):
            build_vars = variation
            break
    else:
        exit_invoke(
            1,
            "Could not find the distribution build vars file.\nTried:\n{}",
            "\n".join(f" - {vv}" for vv in vars_variations),
        )

    packer_tmp_dir = PACKER_TMP_DIR.format(distro_slug)
    if not os.path.exists(packer_tmp_dir):
        os.makedirs(packer_tmp_dir)
    os.chmod(os.path.dirname(packer_tmp_dir), 0o755)
    os.chmod(packer_tmp_dir, 0o755)
    if distro_slug.startswith("windows"):
        scripts_path = os.path.join(packer_tmp_dir, "scripts")
        if not os.path.exists(scripts_path):
            os.makedirs(scripts_path)
        os.chmod(scripts_path, 0o755)
        with open(os.path.join(scripts_path, "Install-Git.ps1"), "w") as wfh:
            wfh.write("")
    for name in ("states", "win_states", "pillar", "conf"):
        path = os.path.join(packer_tmp_dir, name)
        if not os.path.exists(path):
            os.makedirs(path)
        os.chmod(path, 0o755)

    cmd = "packer"
    _binary_install_check(cmd)
    if validate is True:
        packer_command = "validate"
        cmd += f" {packer_command}"
    elif init is True:
        packer_command = "init"
        cmd += f" {packer_command}"
    elif pull is True:
        packer_command = "console"
        cmd += f" {packer_command}"
    else:
        packer_command = "build"
        cmd += f" {packer_command}"
        if debug is True:
            cmd += " -debug -on-error=ask"
        if force:
            cmd += " -force"
        cmd += TIMESTAMP_UI
    cmd += f" -var-file={build_vars}"
    cmd += f" -only=vagrant.{distro}-{distro_arch}"
    if staging is True:
        build_type = "ci-staging"
    else:
        build_type = "ci"
    cmd += f" -var build_type={build_type}"
    if salt_pr and salt_pr.lower() != "null":
        cmd += f" -var salt_pr={salt_pr}"

    cmd += f" -var os_name={distro}"
    cmd += f" -var vagrantcloud_user={vagrantcloud_user}"
    cmd += f" -var output_box_name={output_box_name}"
    cmd += f" -var output_box_version={output_box_version}"
    cmd += f" -var distro_slug={distro_slug} {build_template}"
    if pull is True:
        cmd = f"echo variables | {cmd}"
        ret = ctx.run(cmd, echo=False)
        variables = {}
        for line in ret.stdout.splitlines():
            if not line:
                continue
            if line.startswith(">"):
                continue
            key, value = line.split(":")
            key = key.strip().replace("var.", "")
            value = value.strip()[1:-1]
            variables[key] = value
        try:
            cmd = f"vagrant box list | grep {variables['src_box_name']}"
            if variables.get("src_box_version"):
                cmd += f" | grep {variables['src_box_version']}"
            ctx.run(cmd, echo=True)
            if force is not True:
                pull = False
            print(
                f"The image {variables['src_box_name']} already exists...",
                file=sys.stderr,
                flush=True,
            )
        except UnexpectedExit:
            pass

        if pull is True:
            cmd = "vagrant box add --provider=virtualbox"
            if variables.get("src_box_version"):
                cmd += f" --box-version={variables['src_box_version']}"
            cmd += f" {variables['src_box_name']}"
            ctx.run(cmd, echo=True)
    else:
        try:
            ctx.run(cmd, echo=True)
            if no_test is False and packer_command == "build":
                with ctx.cd("target"):
                    try:
                        ctx.run(
                            f"vagrant box add --provider=virtualbox --name={output_box_name}-test --force package.box",
                            echo=True,
                        )
                        ctx.run("vagrant up --provider=virtualbox output", echo=True)
                        ret = ctx.run(f"vagrant ssh -c '{test_command}' output", echo=True)
                        if getattr(ret, test_command_expected_std).strip() == "":
                            raise BuildFailed("Failed to get nox version from the box")
                    finally:
                        try:
                            ctx.run("vagrant destroy --force output")
                        finally:
                            ctx.run(f"vagrant box remove --force {output_box_name}-test", echo=True)
                    try:
                        ctx.run(
                            f"vagrant cloud box create --no-private {vagrantcloud_user}/{output_box_name}"
                        )
                    except UnexpectedExit:
                        # The command will fail if we already created the box
                        pass

                    # Get the sha256sum of the newly built image
                    ret = ctx.run("sha256sum package.box", echo=True)
                    sha256sum = ret.stdout.split()[0].strip()
                    # Publish the newly built image
                    distro_display_name = DISTRO_DISPLAY_NAMES.get(distro, distro.title())
                    short_description = (
                        f"{build_type.upper()} Image of {distro_display_name} "
                        f"{distro_version} For {distro_arch.upper()}"
                    )
                    ctx.run(
                        "vagrant cloud publish --force --no-private --no-tty "
                        f"--short-description='{short_description}' "
                        f"--checksum={sha256sum} --checksum-type=sha256 "
                        f"{vagrantcloud_user}/{output_box_name} {output_box_version} "
                        "virtualbox package.box",
                        echo=True,
                    )
                    # Release the newly built image
                    ctx.run(
                        "vagrant cloud version release --force "
                        f"{vagrantcloud_user}/{output_box_name} {output_box_version}",
                        echo=True,
                    )
        except (UnexpectedExit, BuildFailed) as exc:
            if isinstance(exc, BuildFailed):
                print(exc, file=sys.stderr, flush=True)
            sys.exit(1)
